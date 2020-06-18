class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    {
      paths: {
        record.path => {
          record.method.downcase => {
            summary: record.description,
            responses: {
              record.status.to_s => {
                content: {
                  'application/json': { # TODO: Extract this
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
            properties: build_properties(record),
          },
        },
      },
    }
  end

  private

  def build_properties(record)
    {}.tap do |properties|
      record.body.each do |key, value|
        properties[key] = {
          type: build_type(value),
        }
        # TODO: set items for array
      end
    end
  end

  def build_type(value)
    case value
    when String
      'string'
    when TrueClass, FalseClass
      'boolean'
    when Array
      'array'
    else
      raise NotImplementedError, "type inference is not implemented for: #{value.inspect}"
    end
  end
end
