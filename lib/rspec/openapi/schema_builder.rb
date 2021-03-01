class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    response = {
      description: record.response_description,
    }

    if record.response_body
      response[:content] = {
        normalize_content_type(record.response_content_type) => {
          schema: build_property(record.response_body),
          example: (record.response_body if example_enabled?),
        }.compact,
      }
    end

    {
      paths: {
        normalize_path(record.path) => {
          record.method.downcase => {
            summary: record.summary,
            description: record.operation_description,
            tags: record.tags,
            parameters: build_parameters(record),
            requestBody: build_request_body(record),
            responses: {
              record.status.to_s => response,
            },
          }.compact,
        },
      },
    }
  end

  private

  def example_enabled?
    RSpec::OpenAPI.enable_example
  end

  def build_parameters(record)
    parameters = []

    record.path_params.each do |key, value|
      parameters << {
        name: key.to_s,
        in: 'path',
        required: true,
        schema: build_property(try_cast(value)),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    record.query_params.each do |key, value|
      parameters << {
        name: key.to_s,
        in: 'query',
        schema: build_property(try_cast(value)),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    record.headers.each do |key, value|
      parameters << {
        name: key.to_s,
        in: 'header',
        required: true,
        schema: build_property(try_cast(value)),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    return nil if parameters.empty?
    parameters
  end

  def build_request_body(record)
    return nil if record.request_content_type.nil?
    return nil if record.request_params.empty?

    {
      content: {
        normalize_content_type(record.request_content_type) => {
          schema: build_property(record.request_params),
          example: (build_example(record.request_params) if example_enabled?),
        }.compact
      }
    }
  end

  def build_property(value)
    property = build_type(value)

    case value
    when Array
      property[:items] = build_property(value.first)
    when Hash
      property[:properties] = {}.tap do |properties|
        value.each do |key, v|
          properties[key] = build_property(v)
        end
      end
    end
    property
  end

  def build_type(value)
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

  # Convert an always-String param to an appropriate type
  def try_cast(value)
    begin
      Integer(value)
    rescue TypeError, ArgumentError
      value
    end
  end

  def build_example(value)
    return nil if value.nil?
    value = value.dup
    value.each do |key, v|
      if v.is_a?(ActionDispatch::Http::UploadedFile)
        value[key] = v.original_filename
      end
    end
  end

  def normalize_path(path)
    path.gsub(%r|/:([^:/]+)|, '/{\1}')
  end

  def normalize_content_type(content_type)
    content_type&.sub(/;.+\z/, '')
  end
end
