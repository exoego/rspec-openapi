# frozen_string_literal: true

require_relative 'hash_helper'

# Converts between the internal `nullable: true` form and the 3.1+ JSON Schema
# null form (`type: [..., 'null']`). The builder and merger only use `nullable`;
# normalize! runs on read, to_json_schema! on write.
class << RSpec::OpenAPI::NullableConverter = Object.new
  NULL_VARIANT = { type: 'null' }.freeze
  NULLABLE_VARIANT = { nullable: true }.freeze

  # Variants come before their oneOf, so a oneOf sees its variants converted.
  def to_json_schema!(node)
    RSpec::OpenAPI::HashHelper.each_schema(node) { |schema| nullable_to_type_null!(schema) }
    node
  end

  def normalize!(node)
    RSpec::OpenAPI::HashHelper.each_schema(node) { |schema| type_null_to_nullable!(schema) }
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

  # A null variant beside a typed oneOf is written back as a variant, so it
  # stays one. Beside a typeless oneOf it folds into the wrapper, where the
  # builder and merger keep nullable.
  def type_null_to_nullable!(schema)
    schema[:nullable] = true if !schema.key?(:type) && schema[:oneOf]&.delete(NULLABLE_VARIANT)

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
end
