# frozen_string_literal: true

RSpec::OpenAPI::SchemaBuilder = Object.new
require_relative 'schema_builder/build_context'

class << RSpec::OpenAPI::SchemaBuilder
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    {
      paths: {
        normalize_path(record.path) => {
          record.http_method.downcase => build_operation(record),
        },
      },
    }
  end

  private

  def build_operation(record)
    http_method = record.http_method.downcase
    # GET and DELETE never have a request body in OpenAPI.
    request_body = ['delete', 'get'].include?(http_method) ? nil : build_request_body(record)
    {
      summary: record.summary,
      tags: record.tags,
      operationId: record.operation_id,
      security: record.security,
      deprecated: record.deprecated ? true : nil,
      parameters: build_parameters(record),
      requestBody: request_body,
      responses: { record.status.to_s => build_response(record) },
    }.compact
  end

  def build_response(record)
    # `:none` opts out of recording, so the description is provisional. Stash
    # it under a fallback key; SchemaCleaner promotes it to `description` only
    # if no documented test has set one. This makes the merge result
    # independent of RSpec's random execution order.
    desc_key = record.response_example_mode == :none ? :_fallback_description : :description
    response = { desc_key => record.description }

    response_headers = build_response_headers(record)
    response[:headers] = response_headers unless response_headers.empty?

    if record.response_body && !normalize_content_type(record.response_content_type).nil?
      response[:content] = build_content(record)
    end

    response
  end

  def build_content(record)
    disposition = normalize_content_disposition(record.response_content_disposition)
    content_type = normalize_content_type(record.response_content_type)
    ctx = BuildContext.new(record: record, context: :response)
    schema = build_property(record.response_body, ctx, disposition: disposition)
    example = response_example(record, disposition: disposition)

    body = build_example_body(schema, record, mode: record.response_example_mode, example: example)
    { content_type => body }
  end

  # Returns the per-content-type body (schema + optional example/examples).
  # Shared by response content and request body to keep example_mode handling in one place.
  def build_example_body(schema, record, mode:, example:)
    return { schema: schema } if !example_enabled?(record) || mode == :none

    case mode
    when :multiple
      { schema: schema, examples: { record.example_key => build_named_example(record, example) } }
    else
      # :single (default)
      # :single may emit nil example or nil _example_summary; compact strips them.
      { schema: schema, example: example, **example_metadata(record) }.compact
    end
  end

  def response_example(record, disposition:)
    return nil if !example_enabled?(record) || disposition

    record.response_body
  end

  def build_named_example(record, value)
    summary = example_summary(record)
    summary ? { summary: summary, value: value } : { value: value }
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
    parameters = record.path_params.map do |key, value|
      build_parameter(key, value, location: 'path', record: record)
    end

    parameters += flatten_query_params(record.query_params).map do |key, value|
      build_parameter(key, value, location: 'query', record: record)
    end

    parameters += record.request_headers.map do |key, value|
      build_parameter(key, value, location: 'header', record: record)
    end

    parameters&.empty? ? nil : parameters
  end

  # `compound_name` and `required` follow from `location`:
  # path/header params are always required and use bracketed names like
  # `key[subkey]`; query params are pre-flattened and may be optional.
  def build_parameter(key, value, location:, record:)
    is_query = location == 'query'
    compound_name = !is_query
    required = is_query ? record.required_request_params.include?(key) : true
    cast = try_cast(value)
    ctx = BuildContext.new(record: record, context: :request, key: key, path: key.to_s)
    {
      name: compound_name ? build_parameter_name(key, value) : key,
      in: location,
      required: required,
      schema: build_property(cast, ctx),
      example: (cast if example_enabled?(record)),
    }.compact
  end

  def build_response_headers(record)
    record.response_headers.to_h do |key, value|
      ctx = BuildContext.new(record: record, context: :response, key: key, path: key.to_s)
      [key, { schema: build_property(try_cast(value), ctx) }]
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
    ctx = BuildContext.new(record: record, context: :request)
    schema = build_property(record.request_params, ctx)
    example = example_enabled?(record) ? build_example(record.request_params) : nil

    body = build_example_body(schema, record, mode: record.request_example_mode, example: example)
    { content: { content_type => body } }
  end

  def build_property(value, ctx, disposition: nil)
    format = disposition ? 'binary' : infer_format(ctx.key, ctx.record)
    enum = infer_enum(ctx.path, ctx.record, ctx.context)
    property = build_type(value, format: format, enum: enum)

    case value
    when Array
      property[:items] = value.empty? ? {} : build_array_items_schema(value, ctx.for_array_items)
    when Hash
      apply_object_schema(property, value, ctx)
    end
    property
  end

  def apply_object_schema(property, value, ctx)
    override = infer_override(ctx.path, ctx.record, ctx.context, :additional_properties)

    if override.is_a?(Hash) && !override.empty?
      # Schema override: the object's keys are dynamic — replace captured
      # `properties` / `required` with the supplied dictionary value schema.
      property[:additionalProperties] = override
      return
    end

    property[:properties] = value.to_h do |k, v|
      [k, build_property(v, ctx.descend(k))]
    end
    property[:required] = property[:properties].keys
    apply_additional_properties(property, override,
                                infer_override(ctx.path, ctx.record, ctx.context, :hybrid_additional_properties),)
  end

  # Hybrid: keep the observed `properties` / `required` and attach
  # `additionalProperties` alongside.
  # - Boolean values are constraints (`false` forbids extras, `true` explicitly allows them).
  # - Hash schema values come from the dedicated `hybrid_additional_properties`
  #   metadata, expressing "known keys + extras of this type".
  def apply_additional_properties(property, override, hybrid_override)
    if [true, false].include?(override)
      property[:additionalProperties] = override
    elsif hybrid_override.is_a?(Hash) && !hybrid_override.empty?
      property[:additionalProperties] = hybrid_override
    end
  end

  def build_type(value, format: nil, enum: nil)
    result = if format
               { type: 'string', format: format }
             else
               case value
               when String then { type: 'string' }
               when Integer then { type: 'integer' }
               when Float then { type: 'number', format: 'float' }
               when TrueClass, FalseClass then { type: 'boolean' }
               when Array then { type: 'array' }
               when Hash then { type: 'object' }
               when ActionDispatch::Http::UploadedFile then { type: 'string', format: 'binary' }
               when NilClass then { nullable: true }
               else raise NotImplementedError, "type detection is not implemented for: #{value.inspect}"
               end
             end

    result[:enum] = enum if enum
    result
  end

  def infer_format(key, record)
    return nil unless key && record

    record.formats&.[](key)
  end

  def infer_enum(path, record, context)
    return nil if !path || !record

    # Keys are already normalized to strings by SharedExtractor.normalize_enum
    record.send("#{context}_enum")&.[](path.to_s)
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

  def adjust_params(hash)
    hash.transform_values! { |v| adjust_value(v) }
  end

  def adjust_value(value)
    case value
    when ActionDispatch::Http::UploadedFile then value.original_filename
    when Hash then adjust_params(value)
    when Array then value.map { |item| adjust_value(item) }
    else value
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

  def build_array_items_schema(array, ctx)
    return {} if array.empty?

    schemas = array.map { |item| build_property(item, ctx) }
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
    property_keys(variations).each_with_object({}) do |key, merged_props|
      all = variations.map { |v| v[:properties]&.[](key) }
      prop_variations = all.reject { |p| p.nil? || p.keys == [:nullable] }
      has_nullable = nullable_present?(all, recursive: allow_recursive_merge)

      next if prop_variations.empty? && !has_nullable

      merged_props[key] = merge_single_property(prop_variations, has_nullable,
                                                variations_total: variations.size,
                                                allow_recursive_merge: allow_recursive_merge,)
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
      else
        merge_multi(prop_variations)
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

  # Combine multiple variations of the same property: flatten existing oneOf
  # entries, recurse into objects and arrays, and combine divergent types into
  # oneOf. Scalar variations of a single type collapse to the first schema.
  def merge_multi(prop_variations)
    return { oneOf: flatten_one_of(prop_variations) } if prop_variations.any? { |p| p.key?(:oneOf) }

    prop_types = prop_variations.map { |p| p[:type] }.compact.uniq
    return one_of_schema(prop_variations) if prop_types.size > 1

    case prop_types.first
    when 'array'
      items_variations = prop_variations.map { |p| p[:items] }.compact
      { type: 'array', items: build_merged_schema_from_variations(items_variations) }
    when 'object'
      build_merged_schema_from_variations(prop_variations)
    else
      prop_variations.first.dup
    end
  end

  def flatten_one_of(prop_variations)
    prop_variations.each_with_object([]) do |prop, options|
      clean = without_nullable(prop)
      if clean.key?(:oneOf)
        options.concat(clean[:oneOf])
      elsif !clean.empty?
        options << clean
      end
    end.uniq
  end

  def without_nullable(prop)
    prop.reject { |k, _| k == :nullable }
  end

  def one_of_schema(variations)
    { oneOf: variations.map { |p| without_nullable(p) }.uniq }
  end
end
