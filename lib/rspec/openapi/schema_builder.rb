# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    response = if record.response_example_mode == :none
                 # `:none` opts out of recording, so the description is provisional.
                 # Stash it under a fallback key; SchemaCleaner promotes it to
                 # `description` only if no documented test has set one. This makes
                 # the merge result independent of RSpec's random execution order.
                 { _fallback_description: record.description }
               else
                 { description: record.description }
               end

    response_headers = build_response_headers(record)
    response[:headers] = response_headers unless response_headers.empty?

    if record.response_body && !normalize_content_type(record.response_content_type).nil?
      response[:content] = build_content(record)
    end

    http_method = record.http_method.downcase
    {
      paths: {
        normalize_path(record.path) => {
          http_method => {
            summary: record.summary,
            tags: record.tags,
            operationId: record.operation_id,
            security: record.security,
            deprecated: record.deprecated ? true : nil,
            parameters: build_parameters(record),
            requestBody: include_nil_request_body?(http_method) ? nil : build_request_body(record),
            responses: {
              record.status.to_s => response,
            },
          }.compact,
        },
      },
    }
  end

  private

  def include_nil_request_body?(http_method)
    ['delete', 'get'].include?(http_method)
  end

  def build_content(record)
    disposition = normalize_content_disposition(record.response_content_disposition)
    content_type = normalize_content_type(record.response_content_type)
    schema = build_property(record.response_body, disposition: disposition, record: record, context: :response)
    example = response_example(record, disposition: disposition)

    body = build_example_body(schema, record, mode: record.response_example_mode, example: example)
    { content_type => body }
  end

  # Returns the per-content-type body (schema + optional example/examples).
  # Shared by response content and request body to keep example_mode handling in one place.
  def build_example_body(schema, record, mode:, example:)
    return { schema: schema }.compact unless example_enabled?(record)

    case mode
    when :none
      { schema: schema }.compact
    when :multiple
      {
        schema: schema,
        examples: { record.example_key => build_named_example(record, example) },
      }.compact
    else # :single (default)
      {
        schema: schema,
        example: example,
        **example_metadata(record),
      }.compact
    end
  end

  def response_example(record, disposition:)
    return nil if !example_enabled?(record) || disposition

    record.response_body
  end

  def build_named_example(record, value)
    summary = example_summary(record)
    example = {}
    example[:summary] = summary if summary
    example[:value] = value
    example
  end

  def example_metadata(record)
    { _example_key: record.example_key, _example_summary: example_summary(record) }
  end

  def example_summary(record)
    return nil unless RSpec::OpenAPI.enable_example_summary
    return nil if record.example_name.nil? || record.example_name.empty?

    record.example_name
  end

  def example_enabled?(record)
    record.example_enabled
  end

  def build_parameters(record)
    parameters = []

    record.path_params.each do |key, value|
      parameters << build_parameter(key, value, location: 'path', required: true, record: record, compound_name: true)
    end

    flatten_query_params(record.query_params).each do |key, value|
      parameters << build_parameter(key, value, location: 'query',
                                                required: record.required_request_params.include?(key),
                                                record: record)
    end

    record.request_headers.each do |key, value|
      parameters << build_parameter(key, value, location: 'header', required: true, record: record, compound_name: true)
    end

    parameters.empty? ? nil : parameters
  end

  def build_parameter(key, value, location:, required:, record:, compound_name: false)
    cast = try_cast(value)
    {
      name: compound_name ? build_parameter_name(key, value) : key,
      in: location,
      required: required,
      schema: build_property(cast, key: key, record: record, path: key.to_s, context: :request),
      example: (cast if example_enabled?(record)),
    }.compact
  end

  def build_response_headers(record)
    record.response_headers.each_with_object({}) do |(key, value), headers|
      headers[key] = {
        schema: build_property(try_cast(value), key: key, record: record, path: key.to_s, context: :response),
      }.compact
    end
  end

  def build_parameter_name(key, value)
    key = key.to_s
    if value.is_a?(Hash) && (value_keys = value.keys).size == 1
      value_key = value_keys.first
      build_parameter_name("#{key}[#{value_key}]", value[value_key])
    else
      key
    end
  end

  def flatten_query_params(params, parent_key = nil)
    params.each_with_object({}) do |(key, value), result|
      full_key = parent_key ? "#{parent_key}[#{key}]" : key.to_s

      if value.is_a?(Hash)
        result.merge!(flatten_query_params(value, full_key))
      else
        result[full_key] = value
      end
    end
  end

  def build_request_body(record)
    return nil if record.request_content_type.nil?
    return nil if record.status >= 400 && record.request_example_mode != :multiple

    content_type = normalize_content_type(record.request_content_type)
    schema = build_property(record.request_params, record: record, context: :request)
    example = example_enabled?(record) ? build_example(record.request_params) : nil

    body = build_example_body(schema, record, mode: record.request_example_mode, example: example)
    { content: { content_type => body } }
  end

  def build_property(value, disposition: nil, key: nil, record: nil, path: nil, context: nil)
    format = disposition ? 'binary' : infer_format(key, record)
    enum = infer_enum(path, record, context)

    property = build_type(value, format: format, enum: enum)

    case value
    when Array
      property[:items] = value.empty? ? {} : build_array_items_schema(value, record: record, path: path, context: context)
    when Hash
      override = infer_override(path, record, context, :additional_properties)
      hybrid_override = infer_override(path, record, context, :hybrid_additional_properties)
      if override.is_a?(Hash) && !override.empty?
        # Schema override: the object's keys are dynamic — replace captured
        # `properties` / `required` with the supplied dictionary value schema.
        property[:additionalProperties] = override
      else
        property[:properties] = value.each_with_object({}) do |(k, v), props|
          child_path = path ? "#{path}.#{k}" : k.to_s
          props[k] = build_property(v, record: record, key: k, path: child_path, context: context)
        end
        property[:required] = property[:properties].keys
        # Hybrid: keep the observed `properties` / `required` and attach
        # `additionalProperties` alongside.
        # - Boolean values are constraints (`false` forbids extras, `true`
        #   explicitly allows them).
        # - Hash schema values come from the dedicated `hybrid_additional_properties`
        #   metadata, expressing "known keys + extras of this type".
        if [true, false].include?(override)
          property[:additionalProperties] = override
        elsif hybrid_override.is_a?(Hash) && !hybrid_override.empty?
          property[:additionalProperties] = hybrid_override
        end
      end
    end
    property
  end

  def build_type(value, format: nil, enum: nil)
    result = if format
               { type: 'string', format: format }
             else
               case value
               when String                          then { type: 'string' }
               when Integer                         then { type: 'integer' }
               when Float                           then { type: 'number', format: 'float' }
               when TrueClass, FalseClass           then { type: 'boolean' }
               when Array                           then { type: 'array' }
               when Hash                            then { type: 'object' }
               when ActionDispatch::Http::UploadedFile then { type: 'string', format: 'binary' }
               when NilClass                        then { nullable: true }
               else raise NotImplementedError, "type detection is not implemented for: #{value.inspect}"
               end
             end

    result[:enum] = enum if enum
    result
  end

  def infer_format(key, record)
    return nil if !key || !record || !record.formats

    record.formats[key]
  end

  def infer_enum(path, record, context)
    return nil if !path || !record

    enum_hash = context == :request ? record.request_enum : record.response_enum
    return nil unless enum_hash

    # Keys are already normalized to strings by SharedExtractor.normalize_enum
    enum_hash[path.to_s]
  end

  # Looks up an override for the current path under one of the per-context
  # override maps on the record (e.g. request_additional_properties).
  # For :additional_properties we use `key?` so a literal `false` is
  # distinguishable from "no override"; for :hybrid_additional_properties
  # plain lookup is enough because only Hash values are meaningful.
  def infer_override(path, record, context, kind)
    return nil unless record

    overrides = record.send("#{context}_#{kind}")
    return nil unless overrides

    # path is nil at the body root; nil.to_s == '' lets users target it via { '' => ... }.
    return nil if kind == :additional_properties && !overrides.key?(path.to_s)

    overrides[path.to_s]
  end

  # Convert an always-String param to an appropriate type
  def try_cast(value)
    Integer(value)
  rescue TypeError, ArgumentError
    value
  end

  def build_example(value)
    return nil if value.nil?

    adjust_params(value.dup)
  end

  def adjust_params(value)
    value.each do |key, v|
      case v
      when ActionDispatch::Http::UploadedFile
        value[key] = v.original_filename
      when Hash
        adjust_params(v)
      when Array
        value[key] = v.map { |item| adjust_array_item(item) }
      end
    end
  end

  def adjust_array_item(item)
    case item
    when ActionDispatch::Http::UploadedFile then item.original_filename
    when Hash                               then adjust_params(item)
    else item
    end
  end

  def normalize_path(path)
    path.gsub(%r{/:([^:/]+)}, '/{\1}')
  end

  def normalize_content_type(content_type)
    content_type&.sub(/;.+\z/, '')
  end

  # Same logic as normalize_content_type – strips header parameters after ';'
  alias normalize_content_disposition normalize_content_type

  def build_array_items_schema(array, record: nil, path: nil, context: nil)
    return {} if array.empty?

    schemas = array.map { |item| build_property(item, record: record, path: path, context: context) }
    return schemas.first if schemas.size == 1 || !array.all?(Hash)

    merged = schemas.first.dup
    merged[:properties] = merge_property_variations(schemas, allow_recursive_merge: false)
    merged[:required] = schemas.map { |s| s[:required] || [] }.reduce(:&) || []
    merged
  end

  def build_merged_schema_from_variations(variations)
    return {} if variations.empty?
    return variations.first if variations.size == 1

    types = variations.map { |v| v[:type] }.compact.uniq
    return variations.first unless types.size == 1 && types.first == 'object'

    {
      type: 'object',
      properties: merge_property_variations(variations, allow_recursive_merge: true),
      required: variations.map { |v| v[:required] || [] }.reduce(:&) || [],
    }
  end

  # Merge the per-key property schemas of multiple object variations.
  # When `allow_recursive_merge` is true, objects are recursively merged via
  # build_merged_schema_from_variations and existing oneOf entries are flattened.
  # When false (callsite: array-items merging), divergent property variations
  # become oneOf without recursive descent.
  def merge_property_variations(variations, allow_recursive_merge:)
    {}.tap do |merged_props|
      property_keys(variations).each do |key|
        all = variations.map { |v| v[:properties]&.[](key) }
        prop_variations = all.reject { |p| p.nil? || p.keys == [:nullable] }
        has_nullable = nullable_present?(all, recursive: allow_recursive_merge)

        next if prop_variations.empty? && !has_nullable

        merged_prop = merge_single_property(prop_variations, has_nullable,
                                            variations_total: variations.size,
                                            allow_recursive_merge: allow_recursive_merge)
        merged_props[key] = merged_prop if merged_prop
      end
    end
  end

  def property_keys(variations)
    variations.flat_map { |v| v[:properties]&.keys || [] }.uniq
  end

  # `recursive` mirrors build_merged_schema_from_variations' original rule that
  # also treats `{ ..., nullable: true }` as a nullable signal. Array-items
  # merging only looks at outright nil or `{ nullable: true }` markers.
  def nullable_present?(all_props, recursive:)
    all_props.any? do |p|
      p.nil? || (p.is_a?(Hash) && (p.keys == [:nullable] || (recursive && p[:nullable] == true)))
    end
  end

  def merge_single_property(prop_variations, has_nullable, variations_total:, allow_recursive_merge:)
    return { nullable: true } if prop_variations.empty?

    merged =
      if prop_variations.size == 1
        prop_variations.first.dup
      elsif allow_recursive_merge
        merge_multi_recursive(prop_variations)
      else
        merge_multi_array_items(prop_variations)
      end

    return merged unless merged.is_a?(Hash)

    # In recursive mode, multi-variation merges also flag nullable when the key
    # only appeared in some of the source variations.
    needs_nullable =
      if allow_recursive_merge && prop_variations.size > 1
        has_nullable || prop_variations.size < variations_total
      else
        has_nullable
      end
    merged[:nullable] = true if needs_nullable
    merged
  end

  # Array-items mode: combine multiple variations of the same property without
  # recursing into nested objects/arrays beyond one level.
  def merge_multi_array_items(prop_variations)
    unique_types = prop_variations.map { |p| p[:type] }.compact.uniq

    if unique_types.size > 1
      { oneOf: prop_variations.map { |p| p.reject { |k, _| k == :nullable } }.uniq }
    else
      case unique_types.first
      when 'array'
        items_variations = prop_variations.map { |p| p[:items] }.compact
        { type: 'array', items: build_merged_schema_from_variations(items_variations) }
      when 'object'
        build_merged_schema_from_variations(prop_variations)
      else
        prop_variations.first.dup
      end
    end
  end

  # Recursive-merge mode (used inside build_merged_schema_from_variations):
  # additionally flattens existing oneOf entries and recurses into objects.
  def merge_multi_recursive(prop_variations)
    return { oneOf: flatten_one_of(prop_variations) } if prop_variations.any? { |p| p.key?(:oneOf) }

    prop_types = prop_variations.map { |p| p[:type] }.compact.uniq
    if prop_types.size == 1
      prop_types.first == 'object' ? build_merged_schema_from_variations(prop_variations) : prop_variations.first.dup
    else
      { oneOf: prop_variations.map { |p| p.reject { |k, _| k == :nullable } }.uniq }
    end
  end

  def flatten_one_of(prop_variations)
    options = []
    prop_variations.each do |prop|
      clean = prop.reject { |k, _| k == :nullable }
      if clean.key?(:oneOf)
        options.concat(clean[:oneOf])
      elsif !clean.empty?
        options << clean
      end
    end
    options.uniq
  end
end
