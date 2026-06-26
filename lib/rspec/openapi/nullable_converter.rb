# frozen_string_literal: true

# Converts between the internal `nullable: true` form and the 3.1+ JSON Schema
# null form (`type: [..., 'null']`). The builder and merger only use `nullable`;
# normalize! runs on read, to_json_schema! on write.
class << RSpec::OpenAPI::NullableConverter = Object.new
  # Keys whose values hold user data, not schemas. Their contents must never be
  # rewritten, or a recorded example/default that happens to contain a field
  # named `type` or `nullable` would be silently mangled.
  DATA_KEYS = [:example, :examples, :default, :enum].freeze

  def to_json_schema!(node)
    each_schema(node) { |schema| nullable_to_type_null!(schema) }
    node
  end

  def normalize!(node)
    each_schema(node) { |schema| type_null_to_nullable!(schema) }
    node
  end

  private

  def nullable_to_type_null!(schema)
    return unless schema.delete(:nullable)

    schema[:type] =
      case (type = schema[:type])
      when nil then 'null'
      else [type, 'null']
      end
  end

  def type_null_to_nullable!(schema)
    case (type = schema[:type])
    when 'null'
      schema.delete(:type)
      schema[:nullable] = true
    when Array
      return unless type.include?('null')

      rest = type - ['null']
      if rest.empty?
        schema.delete(:type)
      else
        schema[:type] = rest.one? ? rest.first : rest
      end
      schema[:nullable] = true
    end
  end

  # Yield every schema Hash in the tree, skipping the data subtrees in DATA_KEYS. Each
  # transform mutates only its own node's keys, so the following each still
  # iterates a stable Hash.
  def each_schema(node, &block)
    case node
    when Hash
      yield node
      node.each { |key, value| each_schema(value, &block) unless DATA_KEYS.include?(key) }
    when Array
      node.each { |value| each_schema(value, &block) }
    end
  end
end
