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

      typed = non_empty.reject { |v| nullable_only?(v) }
      return null_schema(non_empty) if typed.empty?

      with_nullable_from(non_empty, merge_typed_variations(widen_integers(typed)))
    end

    def merge_non_object_item_variations(schemas)
      typed = schemas.reject { |schema| nullable_only?(schema) }
      return null_schema(schemas) if typed.empty?

      merged = typed.size == 1 ? typed.first.dup : merge_multi(typed)
      merged[:nullable] = true if typed.size < schemas.size
      merged
    end

    # Merge the per-key property schemas of multiple object variations.
    # `allow_recursive_merge` only decides which signals make a property
    # nullable. Both modes merge the property schemas themselves alike.
    def merge_property_variations(variations, allow_recursive_merge:)
      property_keys(variations).each_with_object({}) do |key, merged_props|
        all = variations.map { |v| v[:properties]&.[](key) }
        read_only = lift_read_only!(all)
        prop_variations = all.reject { |p| p.nil? || nullable_only?(p) }
        has_nullable = nullable_present?(all, recursive: allow_recursive_merge)

        next if prop_variations.empty? && !has_nullable

        merged = if prop_variations.empty?
                   null_schema(all)
                 else
                   merge_single_property(prop_variations, has_nullable,
                                         variations_total: variations.size,
                                         allow_recursive_merge: allow_recursive_merge,)
                 end
        merged[:readOnly] = read_only unless read_only.nil?
        merged_props[key] = merged
      end
    end

    private

    def merge_typed_variations(variations)
      return variations.first if variations.size == 1
      return merge_one_of_variations(variations) if variations.any? { |v| v.key?(:oneOf) }

      types = variations.map { |v| v[:type] }.compact.uniq
      return merge_one_of_variations(variations) if types.size > 1

      case types.first
      when 'object' then merge_object_variations(variations)
      when 'array' then merge_array_item_variations(variations)
      else variations.first
      end
    end

    def with_nullable_from(variations, merged)
      variations.any? { |v| v[:nullable] } ? merged.merge(nullable: true) : merged
    end

    # The variations of one property come from one side of one exchange, so
    # they agree on readOnly. The merge rebuilds the schema, so the caller puts
    # it back on the result, beside a oneOf like nullable. The schemas are the
    # builder's own, so the flag comes off them in place.
    def lift_read_only!(all)
      read_only = all.find { |p| p.is_a?(Hash) && p.key?(:readOnly) }&.[](:readOnly)
      all.each { |p| p&.delete(:readOnly) } unless read_only.nil?
      read_only
    end

    def merge_object_variations(variations)
      merged = { type: 'object' }
      if variations.any? { |v| v.key?(:properties) }
        merged[:properties] = merge_property_variations(variations, allow_recursive_merge: true)
        merged[:required] = variations.map { |v| v[:required] || [] }.reduce(:&) || []
      end
      # Every variation sits at one path, so they all carry the same override.
      additional = variations.find { |v| v.key?(:additionalProperties) }
      merged[:additionalProperties] = additional[:additionalProperties] if additional
      merged
    end

    # Merge multiple array schemas by merging their `items` schemas. A constraint
    # seen in a single sample must not spread to its siblings.
    def merge_array_item_variations(variations)
      merged = variations.first.select do |key, value|
        key == :type || key == :items ||
          variations.all? { |variation| variation.key?(key) && variation[key] == value }
      end
      merged[:items] = merge_variations(variations.map { |v| v[:items] }.compact)
      merged
    end

    def property_keys(variations)
      keys = []
      variations.each { |v| v[:properties]&.each_key { |key| keys << key } }
      keys.uniq!
      keys
    end

    # `recursive` mirrors merge_variations' original rule that also treats
    # `{ ..., nullable: true }` as a nullable signal. Array-items merging only
    # looks at outright nil or `{ nullable: true }` markers.
    def nullable_present?(all_props, recursive:)
      all_props.any? do |p|
        p.nil? || (p.is_a?(Hash) && (nullable_only?(p) || (recursive && p[:nullable] == true)))
      end
    end

    # A nil builds `{ nullable: true }`.
    def nullable_only?(schema)
      schema[:nullable] == true && !schema.key?(:type) && !schema.key?(:oneOf)
    end

    def null_schema(schemas)
      schemas.find { |schema| schema.is_a?(Hash) && nullable_only?(schema) }&.dup || { nullable: true }
    end

    def merge_single_property(prop_variations, has_nullable, variations_total:, allow_recursive_merge:)
      merged =
        if prop_variations.size == 1
          prop_variations.first.dup
        else
          merge_multi(prop_variations)
        end

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
      return merge_one_of_variations(prop_variations) if prop_variations.any? { |p| p.key?(:oneOf) }

      prop_variations = widen_integers(prop_variations)
      prop_types = prop_variations.map { |p| p[:type] }.compact.uniq
      return merge_one_of_variations(prop_variations) if prop_types.size > 1

      case prop_types.first
      when 'array' then merge_array_item_variations(prop_variations)
      when 'object' then merge_variations(prop_variations)
      else prop_variations.first.dup
      end
    end

    def merge_one_of_variations(variations)
      { oneOf: merge_structured_alternatives(widen_integers(flatten_one_of(variations))) }
    end

    def merge_structured_alternatives(alternatives)
      alternatives.group_by { |alternative| alternative[:type] }.flat_map do |type, group|
        ['array', 'object'].include?(type) && group.size > 1 ? [merge_variations(group)] : group
      end
    end

    # Every integer is a number, so integers seen beside numbers are numbers.
    def widen_integers(variations)
      return variations unless variations.any? { |v| v[:type] == 'number' }

      variations.reject { |v| v[:type] == 'integer' }
    end

    def flatten_one_of(prop_variations)
      options = prop_variations.each_with_object([]) do |prop, acc|
        clean = without_nullable(prop)
        if clean.key?(:oneOf)
          acc.concat(clean[:oneOf])
        elsif !clean.empty?
          acc << clean
        end
      end
      sort_by_type(options.uniq)
    end

    def without_nullable(prop)
      prop.reject { |k, _| k == :nullable }
    end

    # The same order the merger keeps, so the document does not depend on which
    # example ran first.
    def sort_by_type(options)
      options.sort_by.with_index { |option, index| [option[:type].to_s, index] }
    end
  end

  private_constant :VariationMerger
end
