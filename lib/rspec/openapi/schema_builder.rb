class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    {
      paths: {
        record.path => {
          record.method.downcase => {
            summary: "#{record.controller}##{record.action}",
            responses: {
              record.status.to_s => {
                description: record.description,
                content: {
                  record.content_type => {
                    schema: build_property(record.response),
                  },
                },
              },
            },
          },
        },
      },
    }
  end

  private

  def build_property(value)
    property = { type: build_type(value) }
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
      'string'
    when Integer
      'integer'
    when TrueClass, FalseClass
      'boolean'
    when Array
      'array'
    when Hash
      'object'
    when NilClass
      'null'
    else
      raise NotImplementedError, "type detection is not implemented for: #{value.inspect}"
    end
  end
end
