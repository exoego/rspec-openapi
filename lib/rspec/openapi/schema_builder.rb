# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    response = {
      description: record.description,
    }

    response_headers = build_response_headers(record)
    response[:headers] = response_headers unless response_headers.empty?

    if record.response_body
      disposition = normalize_content_disposition(record.response_content_disposition)

      has_content = !normalize_content_type(record.response_content_type).nil?
      if has_content
        response[:content] = {
          normalize_content_type(record.response_content_type) => {
            schema: build_property(record.response_body, disposition: disposition, record: record),
            example: response_example(record, disposition: disposition),
          }.compact,
        }
      end
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
    %w[delete get].include?(http_method)
  end

  def enrich_with_required_keys(obj)
    obj[:required] = obj[:properties]&.keys || []
    obj
  end

  def response_example(record, disposition:)
    return nil if !example_enabled? || disposition

    record.response_body
  end

  def example_enabled?
    RSpec::OpenAPI.enable_example
  end

  def build_parameters(record)
    path_params = record.path_params.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'path',
        required: true,
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    query_params = record.query_params.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'query',
        required: record.required_request_params.include?(key),
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    header_params = record.request_headers.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'header',
        required: true,
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    parameters = path_params + query_params + header_params

    return nil if parameters.empty?

    parameters
  end

  def build_response_headers(record)
    headers = {}

    record.response_headers.each do |key, value|
      headers[key] = {
        schema: build_property(try_cast(value), key: key, record: record),
      }.compact
    end

    headers
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

  def build_request_body(record)
    return nil if record.request_content_type.nil?
    return nil if record.status >= 400

    {
      content: {
        normalize_content_type(record.request_content_type) => {
          schema: build_property(record.request_params, record: record),
          example: (build_example(record.request_params) if example_enabled?),
        }.compact,
      },
    }
  end

  def build_property(value, disposition: nil, key: nil, record: nil)
    format = disposition ? 'binary' : infer_format(key, record)

    property = build_type(value, format: format)

    case value
    when Array
      property[:items] = if value.empty?
                           {} # unknown
                         else
                           build_property(value.first, record: record)
                         end
    when Hash
      property[:properties] = {}.tap do |properties|
        value.each do |key, v|
          properties[key] = build_property(v, record: record, key: key)
        end
      end
      property = enrich_with_required_keys(property)
    end
    property
  end

  def build_type(value, format: nil)
    return { type: 'string', format: format } if format

    case value
    when String
      { type: 'string' }
    when Integer
      { type: 'integer' }
    when Float
      { type: 'number', format: 'float' }
    when TrueClass, FalseClass
      { type: 'boolean' }
    when Array
      { type: 'array' }
    when Hash
      { type: 'object' }
    when ActionDispatch::Http::UploadedFile
      { type: 'string', format: 'binary' }
    when NilClass
      { nullable: true }
    else
      raise NotImplementedError, "type detection is not implemented for: #{value.inspect}"
    end
  end

  def infer_format(key, record)
    return nil if !key || !record || !record.formats

    record.formats[key]
  end

  # Convert an always-String param to an appropriate type
  def try_cast(value)
    Integer(value)
  rescue TypeError, ArgumentError
    value
  end

  def build_example(value)
    return nil if value.nil?

    value = value.dup
    adjust_params(value)
  end

  def adjust_params(value)
    value.each do |key, v|
      case v
      when ActionDispatch::Http::UploadedFile
        value[key] = v.original_filename
      when Hash
        adjust_params(v)
      when Array
        result = v.map do |item|
          case item
          when ActionDispatch::Http::UploadedFile
            item.original_filename
          when Hash
            adjust_params(item)
          else
            item
          end
        end
        value[key] = result
      end
    end
  end

  def normalize_path(path)
    path.gsub(%r{/:([^:/]+)}, '/{\1}')
  end

  def normalize_content_type(content_type)
    content_type&.sub(/;.+\z/, '')
  end

  def normalize_content_disposition(content_disposition)
    content_disposition&.sub(/;.+\z/, '')
  end
end
