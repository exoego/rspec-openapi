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
                    schema: {
                      '$ref': '#/components/schemas/Record', # TODO: generate name
                    },
                  },
                },
              },
            },
          },
        },
      },
      components: {
        schemas: {
          Record: { # TODO: generate name
            type: 'object',
            properties: build_properties(record.response),
          },
        },
      },
    }
  end

  private

  def build_properties(value)
    {}.tap do |properties|
      value.each do |key, value|
        properties[key] = build_property(value)
      end
    end
  end

  def build_property(value)
    property = { type: build_type(value) }
    case value
    when Array
      # TODO: support merging attributes across all elements
      property[:items] = build_property(value.first)
    when Hash
      property[:properties] = build_properties(value)
    end
    property
  end

  def build_type(value)
    case value
    when String
      'string'
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
