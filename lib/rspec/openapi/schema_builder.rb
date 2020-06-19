class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    {
      paths: {
        record.path => {
          record.method.downcase => {
            summary: "#{record.controller}##{record.action}",
            parameters: build_parameters(record),
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
          }.compact,
        },
      },
    }
  end

  private

  def build_parameters(record)
    parameters = []

    record.path_params.each do |key, value|
      next if %i[controller action].include?(key)

      parameters << {
        name: key.to_s,
        in: 'path',
        schema: build_property(
          begin
            Integer(value)
          rescue TypeError, ArgumentError
            value
          end
        ),
      }
    end

    if parameters.empty?
      return nil
    end
    parameters
  end

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
