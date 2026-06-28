# frozen_string_literal: true

# Shared extractor for extracting OpenAPI metadata from RSpec examples
class SharedExtractor
  VALID_EXAMPLE_MODES = [:none, :single, :multiple].freeze

  EXAMPLE_MODE_MULTIPLE_SHORTHAND_WARNING = <<~MSG.tr("\n", ' ').strip.freeze
    [rspec-openapi] DEPRECATION: example_mode: :multiple currently means
    { request: :single, response: :multiple }. A future major version will
    change it to { request: :multiple, response: :multiple } (both sides
    multi). Specify the hash form explicitly to lock in current behavior or
    opt in early.
  MSG

  def self.build_request_response(env, response_array)
    request = ActionDispatch::Request.new(env)
    request.body.rewind if request.body.respond_to?(:rewind)
    [request, ActionDispatch::TestResponse.new(*response_array)]
  end

  def self.attributes(example)
    metadata = merge_openapi_metadata(example.metadata)
    request_example_mode, response_example_mode = normalize_example_mode(metadata[:example_mode], example)
    response_additional_properties, request_additional_properties = resolve_additional_properties(metadata)
    response_hybrid_additional_properties, request_hybrid_additional_properties =
      resolve_hybrid_additional_properties(metadata)
    # Enum support: response_enum and request_enum can override the general enum
    base_enum = normalize_enum(metadata[:enum])

    {
      summary: metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example),
      tags: metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example),
      formats: metadata[:formats] || RSpec::OpenAPI.formats_builder.curry.call(example),
      operation_id: metadata[:operation_id],
      required_request_params: metadata[:required_request_params] || [],
      security: metadata[:security],
      description: metadata[:description] || RSpec::OpenAPI.description_builder.call(example),
      deprecated: metadata[:deprecated],
      request_example_mode: request_example_mode,
      response_example_mode: response_example_mode,
      example_key: resolve_example_key(metadata, example),
      example_name: metadata[:example_name] || RSpec::OpenAPI.example_name_builder.call(example),
      response_enum: normalize_enum(metadata[:response_enum]) || base_enum,
      request_enum: normalize_enum(metadata[:request_enum]) || base_enum,
      response_additional_properties: response_additional_properties,
      request_additional_properties: request_additional_properties,
      response_hybrid_additional_properties: response_hybrid_additional_properties,
      request_hybrid_additional_properties: request_hybrid_additional_properties,
    }
  end

  def self.resolve_example_key(metadata, example)
    example_name = metadata[:example_name] || RSpec::OpenAPI.example_name_builder.call(example)
    raw_example_key = metadata[:example_key] || example_name
    example_key = RSpec::OpenAPI::ExampleKey.normalize(raw_example_key)
    example_key = 'default' if example_key.nil? || example_key.empty?
    example_key
  end

  def self.resolve_additional_properties(metadata)
    base = normalize_additional_properties(metadata[:additional_properties])
    response = normalize_additional_properties(metadata[:response_additional_properties]) || base
    request = normalize_additional_properties(metadata[:request_additional_properties]) || base
    [response, request]
  end

  def self.resolve_hybrid_additional_properties(metadata)
    base = normalize_additional_properties(metadata[:hybrid_additional_properties])
    response = normalize_additional_properties(metadata[:response_hybrid_additional_properties]) || base
    request = normalize_additional_properties(metadata[:request_hybrid_additional_properties]) || base
    [response, request]
  end

  def self.normalize_enum(enum_hash)
    return nil if enum_hash.nil? || enum_hash.empty?

    # Convert all keys to strings for consistent lookup
    enum_hash.transform_keys(&:to_s)
  end

  def self.normalize_additional_properties(hash)
    return nil if hash.nil? || hash.empty?

    hash.each_with_object({}) do |(path, schema), result|
      result[path.to_s] = RSpec::OpenAPI::KeyTransformer.symbolize(schema)
    end
  end

  def self.merge_openapi_metadata(metadata)
    collect_openapi_metadata(metadata).reduce({}, &:merge)
  end

  def self.collect_openapi_metadata(metadata)
    [].tap do |result|
      result.unshift(metadata[:openapi]) if metadata[:openapi]

      group = metadata.fetch(:example_group) { metadata[:parent_example_group] }
      while group
        result.unshift(group[:openapi]) if group[:openapi]
        group = group[:parent_example_group]
      end
    end
  end

  # Returns [request_mode, response_mode]. Accepts either a bare Symbol/String
  # (applied to both sides, except :multiple which is treated as a backward-compat
  # shorthand for { request: :single, response: :multiple } and emits a one-time
  # deprecation warning) or a Hash with :request / :response keys.
  def self.normalize_example_mode(value, example = nil)
    return [:single, :single] if value.nil?

    case value
    when Hash
      [
        normalize_example_mode_hash_value(value, :request, example),
        normalize_example_mode_hash_value(value, :response, example),
      ]
    when Symbol, String
      mode = coerce_example_mode_value(value, example)
      if mode == :multiple
        warn_example_mode_multiple_shorthand
        [:single, :multiple]
      else
        [mode, mode]
      end
    else
      raise ArgumentError, example_mode_error(value, example)
    end
  end

  def self.coerce_example_mode_value(value, example)
    raise ArgumentError, example_mode_error(value, example) unless value.is_a?(String) || value.is_a?(Symbol)

    mode = value.to_s.strip.downcase.to_sym
    return mode if VALID_EXAMPLE_MODES.include?(mode)

    raise ArgumentError, example_mode_error(value, example)
  end

  def self.normalize_example_mode_hash_value(hash, key, example)
    raw = hash[key]
    raw = hash[key.to_s] if raw.nil?
    return :single if raw.nil?

    coerce_example_mode_value(raw, example)
  end

  def self.warn_example_mode_multiple_shorthand
    return if @warned_example_mode_multiple_shorthand

    @warned_example_mode_multiple_shorthand = true
    Kernel.warn(EXAMPLE_MODE_MULTIPLE_SHORTHAND_WARNING)
  end

  def self.example_mode_error(value, example)
    context = example&.full_description
    context = " (example: #{context})" if context
    "example_mode must be a Symbol/String in #{VALID_EXAMPLE_MODES.inspect} " \
      "or a Hash with :request/:response keys, got #{value.inspect}#{context}"
  end
end
