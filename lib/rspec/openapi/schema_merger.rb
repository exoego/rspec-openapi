# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def merge!(base, spec)
    spec = RSpec::OpenAPI::KeyTransformer.symbolize(spec)
    base.replace(RSpec::OpenAPI::KeyTransformer.symbolize(base))
    merge_schema!(base, spec)
  end

  SIMILARITY_THRESHOLD = 0.5

  private

  # Not doing `base.replace(deep_merge(base, spec))` to preserve key orders.
  # Also this needs to be aware of OpenAPI details because a Hash-like structure
  # may be an array whose Hash elements have a key name.
  #
  # TODO: Should we probably force-merge `summary` regardless of manual modifications?
  def merge_schema!(base, spec)
    if (options = base[:oneOf])
      merge_closest_match!(options, spec)

      return base
    end

    # When the new spec converts an object to a dictionary (introduces
    # `additionalProperties` on a node that previously had `properties` /
    # `required`), drop the stale fields so the merged result reflects the
    # new intent. We only prune when base does not already declare
    # `additionalProperties`, to preserve manual edits that intentionally
    # combine fixed and dynamic keys.
    if spec.is_a?(Hash) && spec.key?(:additionalProperties) && !base.key?(:additionalProperties)
      base.delete(:properties)
      base.delete(:required)
    end

    spec.each do |key, value|
      if base[key].is_a?(Hash) && value.is_a?(Hash)
        # Handle example/examples conflict - convert to examples when mixed
        normalize_example_fields!(base[key], value)

        # If the new value has oneOf, replace the entire value instead of merging
        if value.key?(:oneOf)
          base[key] = value
        else
          merge_schema!(base[key], value) unless base[key].key?(:$ref)
        end
      elsif base[key].is_a?(Array) && value.is_a?(Array)
        # parameters need to be merged as if `name` and `in` were the Hash keys.
        merge_arrays(base, key, value)
      else
        # do not ADD `properties` or `required` fields if `additionalProperties` field is present
        base[key] = value unless base.key?(:additionalProperties) && [:properties, :required].include?(key)
      end
    end
    base
  end

  def merge_arrays(base, key, value)
    base[key] = case key
                when :parameters
                  merge_parameters(base, key, value)
                when :required
                  # Preserve properties that appears in all test cases
                  value & base[key]
                else
                  # last one wins
                  value
                end
  end

  def merge_parameters(base, key, value)
    base_params = index_parameters_by_identity(base[key])
    new_params = index_parameters_by_identity(value)

    base[key] = (base_params.keys | new_params.keys).map do |param_key|
      base_param = base_params[param_key]
      new_param = new_params[param_key]

      if base_param && new_param
        merge_parameter_with_schema(base_param, new_param)
      elsif new_param
        # Parameter only in the new spec. Treat as optional unless its `required: true`
        # came from explicit `required_request_params` metadata — distinguishable only
        # for `query`, where the schema_builder default is `required: false`. `header`
        # defaults to `required: true`, so the value alone can't signal user intent.
        new_param[:in] == 'query' && new_param[:required] ? new_param : mark_optional_unless_path(new_param)
      else
        mark_optional_unless_path(base_param)
      end
    end
  end

  # OpenAPI requires `in: path` parameters to be `required: true`, so this leaves
  # them untouched.
  def mark_optional_unless_path(parameter)
    return parameter if parameter[:in] == 'path'

    parameter.merge(required: false)
  end

  def merge_parameter_with_schema(base_param, new_param)
    base_schema = base_param[:schema]
    new_schema = new_param[:schema]

    # If schemas have different types, create a oneOf
    merged = if base_schema && new_schema && schemas_have_different_types?(base_schema, new_schema)
               merged_schema = merge_schemas_into_one_of(base_schema, new_schema)
               base_param.merge(new_param).merge(schema: merged_schema)
             else
               base_param.merge(new_param)
             end

    # Once a parameter has been seen missing in any earlier test case, keep it optional
    # even if later test cases mark it required again.
    merged = mark_optional_unless_path(merged) if base_param[:required] == false || new_param[:required] == false

    merged
  end

  def schemas_have_different_types?(schema1, schema2)
    # If either already has oneOf, we need to merge into it
    return true if schema1[:oneOf] || schema2[:oneOf]

    type1 = schema1[:type]
    type2 = schema2[:type]

    type1 && type2 && type1 != type2
  end

  def merge_schemas_into_one_of(base_schema, new_schema)
    existing_types = extract_schema_types(base_schema)
    new_types = extract_schema_types(new_schema)

    all_types = existing_types + new_types
    all_types.uniq!

    # If only one type remains, return it directly
    return all_types.first if all_types.size == 1

    { oneOf: all_types }
  end

  def extract_schema_types(schema)
    if schema[:oneOf]
      schema[:oneOf].map { |s| s.reject { |k, _| k == :example } }
    else
      [schema.reject { |k, _| k == :example }]
    end
  end

  def index_parameters_by_identity(parameters)
    parameters.to_h { |p| [[p[:name], p[:in]], p] }
  end

  # Normalize example/examples fields when there's a conflict
  # OpenAPI spec doesn't allow both example and examples in the same object
  def normalize_example_fields!(base, spec)
    if base.key?(:example) && spec.key?(:examples)
      convert_example_to_examples!(base)
    elsif base.key?(:examples) && spec.key?(:example)
      convert_example_to_examples!(spec)
    end
  end

  def convert_example_to_examples!(hash)
    name = RSpec::OpenAPI::ExampleKey.normalize(hash.delete(:_example_key)) || 'default'
    summary = hash.delete(:_example_summary)
    value = hash.delete(:example)
    example = {}
    example[:summary] = summary if summary
    example[:value] = value
    hash[:examples] = { name => example }
  end

  def merge_closest_match!(options, spec)
    score, option = options.map { |option| [similarity(option, spec), option] }.max_by(&:first)

    return if option&.key?(:$ref)

    return if spec[:oneOf]

    if score.to_f > SIMILARITY_THRESHOLD
      merge_schema!(option, spec)
    else
      options.push(spec)
    end
  end

  def similarity(first, second)
    return 1 if first == second

    score =
      case [first.class, second.class]
      when [Array, Array]
        (first & second).size / [first.size, second.size].max.to_f
      when [Hash, Hash]
        return 1 if first.merge(second).key?(:$ref)

        intersection = first.keys & second.keys
        total_size = [first.size, second.size].max.to_f

        intersection.sum { |key| similarity(first[key], second[key]) } / total_size
      else
        0
      end

    score.finite? ? score : 0
  end
end
