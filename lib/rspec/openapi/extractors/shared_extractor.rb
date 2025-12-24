# frozen_string_literal: true

# Shared extractor for extracting OpenAPI metadata from RSpec examples
class SharedExtractor
  VALID_EXAMPLE_MODES = %i[none single multiple].freeze

  def self.attributes(example)
    metadata = merge_openapi_metadata(example.metadata)
    summary = metadata[:summary] || RSpec::OpenAPI.summary_builder.call(example)
    tags = metadata[:tags] || RSpec::OpenAPI.tags_builder.call(example)
    formats = metadata[:formats] || RSpec::OpenAPI.formats_builder.curry.call(example)
    operation_id = metadata[:operation_id]
    required_request_params = metadata[:required_request_params] || []
    security = metadata[:security]
    description = metadata[:description] || RSpec::OpenAPI.description_builder.call(example)
    deprecated = metadata[:deprecated]
    example_mode = normalize_example_mode(metadata[:example_mode], example)
    example_name = metadata[:example_name] || RSpec::OpenAPI.example_name_builder.call(example)
    raw_example_key = metadata[:example_key] || example_name
    example_key = RSpec::OpenAPI::ExampleKey.normalize(raw_example_key)
    example_key = 'default' if example_key.nil? || example_key.empty?

    [summary, tags, formats, operation_id, required_request_params, security, description, deprecated, example_mode,
     example_key, example_name,]
  end

  def self.merge_openapi_metadata(metadata)
    collect_openapi_metadata(metadata).reduce({}, &:merge)
  end

  def self.collect_openapi_metadata(metadata)
    [].tap do |result|
      current = metadata

      while current
        [current[:example_group], current].each do |meta|
          result.unshift(meta[:openapi]) if meta&.dig(:openapi)
        end

        current = current[:parent_example_group]
      end
    end
  end

  def self.normalize_example_mode(value, example = nil)
    return :single if value.nil?

    raise ArgumentError, example_mode_error(value, example) unless value.is_a?(String) || value.is_a?(Symbol)

    mode = value.to_s.strip.downcase.to_sym
    return mode if VALID_EXAMPLE_MODES.include?(mode)

    raise ArgumentError, example_mode_error(value, example)
  end

  def self.example_mode_error(value, example)
    context = example&.full_description
    context = " (example: #{context})" if context
    "example_mode must be one of #{VALID_EXAMPLE_MODES.inspect}, got #{value.inspect}#{context}"
  end
end
