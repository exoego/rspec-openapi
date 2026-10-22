# frozen_string_literal: true

# Converts between the internal `nullable: true` form and the 3.1+ JSON Schema
# null form (`type: [..., 'null']`). The builder and merger only use `nullable`;
# normalize! runs on read, to_json_schema! on write.
class << RSpec::OpenAPI::NullableConverter = Object.new
  # Keys whose values hold user data, not schemas. Their contents must never be
  # rewritten, or a recorded example/default that happens to contain a field
  # named `type` or `nullable` would be silently mangled.
  DATA_KEYS = [:example, :examples, :default, :enum].freeze
  NULL_VARIANT = { type: 'null' }.freeze
  NULLABLE_VARIANT = { nullable: true }.freeze

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
    return insert_null_variant!(schema[:oneOf]) if schema[:oneOf] && !schema.key?(:type)

    schema[:type] =
      case (type = schema[:type])
      when nil then 'null'
      when Array then type | ['null']
      else [type, 'null']
      end
  end

  def insert_null_variant!(variants)
    return if variants.any? { |variant| accepts_null?(variant) }

    index = variants.index { |variant| variant.is_a?(Hash) && variant[:type].to_s > 'null' } || variants.size
    variants.insert(index, NULL_VARIANT.dup)
  end

  def accepts_null?(variant)
    variant.is_a?(Hash) && Array(variant[:type]).include?('null')
  end

  def type_null_to_nullable!(schema)
    schema[:nullable] = true if schema[:oneOf]&.delete(NULLABLE_VARIANT)

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

  # Yield every schema Hash in the tree, skipping the data subtrees in DATA_KEYS.
  # Variants come before their oneOf, so a oneOf sees its variants converted.
  def each_schema(node, &block)
    case node
    when Hash
      node.each do |key, value|
        if key == :properties && value.is_a?(Hash)
          value.each_value { |property| each_schema(property, &block) }
        elsif !DATA_KEYS.include?(key)
          each_schema(value, &block)
        end
      end
      yield node
    when Array
      node.each { |value| each_schema(value, &block) }
    end
  end
end
