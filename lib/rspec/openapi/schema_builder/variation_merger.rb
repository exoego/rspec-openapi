# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder
  # Merges multiple observed schema variations of the same value (array items,
  # stream items, repeated object properties) into a single OpenAPI schema.
  # Divergent types are combined into oneOf, and keys that only appear in some
  # variations are marked nullable.
  VariationMerger = Object.new

  class << VariationMerger
    def merge_variations(variations)
      # Drop empty `{}` schemas (e.g. items of an empty array) — they carry no
      # type info and would otherwise spuriously mark every property of their
      # populated siblings as nullable via the missing-key nullable rule.
      non_empty = variations.reject(&:empty?)
      return {} if non_empty.empty?
      return non_empty.first if non_empty.size == 1

      types = non_empty.map { |v| v[:type] }.compact.uniq
      return one_of_schema(non_empty) if types.size > 1

      case types.first
      when 'object' then merge_object_variations(non_empty)
      when 'array' then merge_array_item_variations(non_empty)
      else non_empty.first
      end
    end

    def merge_non_object_item_variations(schemas)
      nullable_only = ->(schema) { schema.keys == [:nullable] }
      typed = schemas.reject(&nullable_only)

      merged = typed.size == 1 ? typed.first.dup : merge_multi(typed)
      merged[:nullable] = true if schemas.any?(&nullable_only) && merged.is_a?(Hash)
      merged
    end

    # Merge the per-key property schemas of multiple object variations.
    # When `allow_recursive_merge` is true, objects are recursively merged via
    # merge_variations and existing oneOf entries are flattened.
    # When false (callsite: array-items merging), divergent property variations
    # become oneOf without recursive descent.
    def merge_property_variations(variations, allow_recursive_merge:)
      property_keys(variations).each_with_object({}) do |key, merged_props|
        all = variations.map { |v| v[:properties]&.[](key) }
        prop_variations = all.reject { |p| p.nil? || p.keys == [:nullable] }
        has_nullable = nullable_present?(all, recursive: allow_recursive_merge)

        next if prop_variations.empty? && !has_nullable

        merged_props[key] = merge_single_property(prop_variations, has_nullable,
                                                  variations_total: variations.size,
                                                  allow_recursive_merge: allow_recursive_merge,)
      end
    end

    private

    def merge_object_variations(variations)
      {
        type: 'object',
        properties: merge_property_variations(variations, allow_recursive_merge: true),
        required: variations.map { |v| v[:required] || [] }.reduce(:&) || [],
      }
    end

    # Merge multiple array schemas by merging their `items` schemas.
    def merge_array_item_variations(variations)
      { type: 'array', items: merge_variations(variations.map { |v| v[:items] }.compact) }
    end

    def property_keys(variations)
      variations.flat_map { |v| v[:properties]&.keys || [] }.uniq
    end

    # `recursive` mirrors merge_variations' original rule that also treats
    # `{ ..., nullable: true }` as a nullable signal. Array-items merging only
    # looks at outright nil or `{ nullable: true }` markers.
    def nullable_present?(all_props, recursive:)
      all_props.any? do |p|
        p.nil? || (p.is_a?(Hash) && (p.keys == [:nullable] || (recursive && p[:nullable] == true)))
      end
    end

    def merge_single_property(prop_variations, has_nullable, variations_total:, allow_recursive_merge:)
      return { nullable: true } if prop_variations.empty?

      merged =
        if prop_variations.size == 1
          prop_variations.first.dup
        else
          merge_multi(prop_variations)
        end

      return merged unless merged.is_a?(Hash)

      # In recursive mode, multi-variation merges also flag nullable when the key
      # only appeared in some of the source variations.
      needs_nullable =
        if allow_recursive_merge && prop_variations.size > 1
          has_nullable || prop_variations.size < variations_total
        else
          has_nullable
        end
      merged[:nullable] = true if needs_nullable
      merged
    end

    # Combine multiple variations of the same property: flatten existing oneOf
    # entries, recurse into objects and arrays, and combine divergent types into
    # oneOf. Scalar variations of a single type collapse to the first schema.
    def merge_multi(prop_variations)
      return { oneOf: flatten_one_of(prop_variations) } if prop_variations.any? { |p| p.key?(:oneOf) }

      prop_types = prop_variations.map { |p| p[:type] }.compact.uniq
      return one_of_schema(prop_variations) if prop_types.size > 1

      case prop_types.first
      when 'array' then merge_array_item_variations(prop_variations)
      when 'object' then merge_variations(prop_variations)
      else prop_variations.first.dup
      end
    end

    def flatten_one_of(prop_variations)
      prop_variations.each_with_object([]) do |prop, options|
        clean = without_nullable(prop)
        if clean.key?(:oneOf)
          options.concat(clean[:oneOf])
        elsif !clean.empty?
          options << clean
        end
      end.uniq
    end

    def without_nullable(prop)
      prop.reject { |k, _| k == :nullable }
    end

    def one_of_schema(variations)
      { oneOf: variations.map { |p| without_nullable(p) }.uniq }
    end
  end

  private_constant :VariationMerger
end
