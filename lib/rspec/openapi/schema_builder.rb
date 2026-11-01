# frozen_string_literal: true

RSpec::OpenAPI::SchemaBuilder = Object.new
require_relative 'schema_builder/build_context'
require_relative 'schema_builder/variation_merger'

class << RSpec::OpenAPI::SchemaBuilder
  # Record members holding the per-context lookup maps, by context (and kind).
  ENUM_MEMBERS = { request: :request_enum, response: :response_enum }.freeze
  READ_ONLY_MEMBERS = { request: :request_read_only, response: :response_read_only }.freeze
  OVERRIDE_MEMBERS = {
    additional_properties: {
      request: :request_additional_properties, response: :response_additional_properties,
    },
    hybrid_additional_properties: {
      request: :request_hybrid_additional_properties, response: :response_hybrid_additional_properties,
    },
  }.freeze

  # GET and DELETE never have a request body in OpenAPI.
  BODYLESS_METHODS = ['delete', 'get'].freeze

  # The schema holds symbol keys like the document, and nothing of the record:
  # the data it carries is copied, so the merger can take the schema over.
  #
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    http_method = record.http_method.downcase
    {
      paths: {
        normalize_path(record.path).to_sym => {
          http_method.to_sym => build_operation(record, http_method),
        },
      },
    }
  end

  private

  def build_operation(record, http_method)
    operation = {
      summary: record.summary,
      tags: copy(record.tags),
      operationId: record.operation_id,
      security: copy(record.security),
      deprecated: record.deprecated ? true : nil,
      parameters: build_parameters(record),
      requestBody: BODYLESS_METHODS.include?(http_method) ? nil : build_request_body(record),
      responses: { record.status.to_s.to_sym => build_response(record) },
    }
    operation.compact!
    operation
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
    ctx = BuildContext.root(record, :response)

    if RSpec::OpenAPI.supports_item_schema? && RSpec::OpenAPI.sequential_media_type?(content_type)
      item_schema = build_stream_item_schema(record.response_body, content_type, ctx)
      return { content_type.to_sym => { itemSchema: item_schema } } if item_schema
    end

    schema = build_property(record.response_body, ctx, disposition: disposition)
    example = response_example(record, disposition: disposition)

    body = build_example_body(schema, record, mode: record.response_example_mode, example: example)
    { content_type.to_sym => body }
  end

  def build_stream_item_schema(raw, content_type, ctx)
    items = RSpec::OpenAPI::StreamParser.items(raw, content_type)
    return nil if items.empty?

    variations = items.map { |item| build_property(item, ctx) }
    VariationMerger.merge_variations(variations)
  end

  # Returns the per-content-type body (schema + optional example/examples).
  # Shared by response content and request body to keep example_mode handling in one place.
  def build_example_body(schema, record, mode:, example:)
    return { schema: schema } if !example_enabled?(record) || mode == :none

    case mode
    when :multiple
      { schema: schema, examples: { example_name(record) => build_named_example(record, example) } }
    else
      # :single (default)
      # :single may emit nil example or nil _example_summary; compact strips them.
      body = {
        schema: schema,
        example: example,
        _example_key: record.example_key,
        _example_summary: example_summary(record),
      }
      body.compact!
      body
    end
  end

  def response_example(record, disposition:)
    return nil if !example_enabled?(record) || disposition || record.response_example_mode == :none

    build_example(record.response_body)
  end

  # Named like the loader names the examples it reads back.
  def example_name(record)
    RSpec::OpenAPI::ExampleKey.normalize(record.example_key).to_sym
  end

  def build_named_example(record, value)
    summary = example_summary(record)
    summary ? { summary: summary, value: value } : { value: value }
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
    flatten_query_params(record.query_params).each do |key, value|
      parameters << build_parameter(key, value, location: 'query', record: record)
    end
    record.request_headers.each do |key, value|
      parameters << build_parameter(key, value, location: 'header', record: record)
    end
    parameters.empty? ? nil : parameters
  end

  # Path and header params are always required; query params are pre-flattened
  # by flatten_query_params and may be optional.
  def build_parameter(key, value, location:, record:)
    is_query = location == 'query'
    required = is_query ? record.required_request_params.include?(key) : true
    cast = try_cast(value)
    name = key.to_s
    ctx = BuildContext.root(record, :request, name, key)
    parameter = {
      name: name,
      in: location,
      required: required,
      schema: build_property(cast, ctx),
      example: (cast if example_enabled?(record)),
    }
    parameter.compact!
    parameter
  end

  def build_response_headers(record)
    headers = {}
    record.response_headers.each do |key, value|
      ctx = BuildContext.root(record, :response, key.to_s, key)
      headers[key.to_sym] = { schema: build_property(try_cast(value), ctx) }
    end
    headers
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
    ctx = BuildContext.root(record, :request)
    schema = build_property(record.request_params, ctx)
    example = build_example(record.request_params) if example_enabled?(record) && record.request_example_mode != :none

    body = build_example_body(schema, record, mode: record.request_example_mode, example: example)
    { content: { content_type.to_sym => body } }
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
      property[:additionalProperties] = copy(override)
      return
    end

    # Only an object property can be readOnly. A request that sends a candidate
    # says false, which wins where the two sides meet in one schema (see
    # SchemaMerger).
    read_only = ctx.record[READ_ONLY_MEMBERS.fetch(ctx.context)]
    properties = {}
    required = []
    value.each do |k, v|
      child = build_property(v, ctx.descend(k))
      name = k.to_s
      child[:readOnly] = ctx.context == :response if read_only&.[](name)
      properties[name.to_sym] = child
      required << name
    end
    property[:properties] = properties
    property[:required] = required
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
      property[:additionalProperties] = copy(hybrid_override)
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

    result[:enum] = copy(enum) if enum
    result
  end

  def infer_format(key, record)
    return nil unless key && record

    record.formats&.[](key)
  end

  def infer_enum(path, record, context)
    return nil if !path || !record

    # Keys are already normalized to strings by SharedExtractor.normalize_enum
    record[ENUM_MEMBERS.fetch(context)]&.[](path.to_s)
  end

  # Looks up an override for the current path under one of the per-context
  # override maps on the record (e.g. request_additional_properties).
  # For :additional_properties we use `key?` so a literal `false` is
  # distinguishable from "no override"; for :hybrid_additional_properties
  # plain lookup is enough because only Hash values are meaningful.
  def infer_override(path, record, context, kind)
    overrides = record[OVERRIDE_MEMBERS.fetch(kind).fetch(context)]
    return nil unless overrides

    # path is nil at the body root; nil.to_s == '' lets users target it via { '' => ... }.
    return nil if kind == :additional_properties && !overrides.key?(path.to_s)

    overrides[path.to_s]
  end

  # Convert an always-String param to an appropriate type
  def try_cast(value)
    return true if value == 'true'
    return false if value == 'false'

    Integer(value, exception: false) || value
  end

  # A copy of a recorded value with symbol keys, and the filename of an upload.
  def build_example(value)
    case value
    when Hash
      example = {}
      value.each { |key, item| example[key.to_sym] = build_example(item) }
      example
    when Array then value.map { |item| build_example(item) }
    when ActionDispatch::Http::UploadedFile then value.original_filename
    else value
    end
  end

  # A record may hold what the metadata of a whole example group holds.
  def copy(value)
    RSpec::OpenAPI::KeyTransformer.symbolize(value)
  end

  # gsub copies the path even when nothing matches.
  def normalize_path(path)
    return path unless path.include?(':')

    path.gsub(%r{/:([^:/]+)}, '/{\1}')
  end

  # sub copies the content type even when it carries no parameters.
  def normalize_content_type(content_type)
    return content_type unless content_type&.include?(';')

    content_type.sub(/;.+\z/, '')
  end

  # Same logic as normalize_content_type – strips header parameters after ';'
  alias normalize_content_disposition normalize_content_type

  def build_array_items_schema(array, ctx)
    schemas = array.map { |item| build_property(item, ctx) }
    return schemas.first if schemas.size == 1
    return VariationMerger.merge_non_object_item_variations(schemas) unless array.all?(Hash)

    merged = schemas.first.dup
    merged[:properties] = VariationMerger.merge_property_variations(schemas, allow_recursive_merge: false)
    merged[:required] = schemas.map { |s| s[:required] || [] }.reduce(:&) || []
    merged
  end
end
