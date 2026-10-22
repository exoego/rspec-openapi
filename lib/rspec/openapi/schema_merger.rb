# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaMerger = Object.new
  # Merge spec into base, normalizing the keys of both to symbols first.
  #
  # @param [Hash] base
  # @param [Hash] spec
  def merge!(base, spec)
    base.replace(RSpec::OpenAPI::KeyTransformer.symbolize(base))
    merge_normalized!(base, spec)
  end

  # Same, for a base whose keys are already symbols.
  #
  # Normalizing base rebuilds every hash and array in it. Callers that merge
  # record after record into one document hold a base of thousands of nodes and
  # merge into it twice per request, so paying for that rebuild each time makes
  # the whole build quadratic in the number of requests. A document read back
  # from a file is normalized by SchemaFile, and anything this file builds is
  # normalized by construction, so those callers can skip it.
  #
  # @param [Hash] base
  # @param [Hash] spec
  def merge_normalized!(base, spec)
    merge_schema!(base, RSpec::OpenAPI::KeyTransformer.symbolize(spec))
  end

  SIMILARITY_THRESHOLD = 0.5
  SCHEMA_KEYS = [:schema, :schemas, :itemSchema].freeze
  DATA_KEYS = [:example, :examples, :default, :enum].freeze
  NUMERIC_TYPES = ['integer', 'number'].freeze
  ANNOTATION_KEYS = [
    :title, :description, :deprecated, :readOnly, :writeOnly, :example, :examples, :default, :externalDocs, :xml,
    :discriminator,
  ].freeze

  private

  # Not doing `base.replace(deep_merge(base, spec))` to preserve key orders.
  # Also this needs to be aware of OpenAPI details because a Hash-like structure
  # may be an array whose Hash elements have a key name.
  #
  # TODO: Should we probably force-merge `summary` regardless of manual modifications?
  # The context is :schema under a schema key, :data under a data key, and
  # :document elsewhere. Recorded data stays data however it is shaped, so a
  # field named like a schema key never gets merged as one.
  def merge_schema!(base, spec, context: :document)
    if context != :data
      return merge_one_of!(base, spec) if base[:oneOf]

      prune_stale_object_fields!(base, spec)
    end
    spec = widen_to_number!(base, spec) if context == :schema

    spec.each { |key, value| merge_schema_entry!(base, key, value, context) }
    base
  end

  # Every integer is a number, so a value seen as both is a number. The format
  # of the integer side would be wrong on a number, so only the number's stays.
  def widen_to_number!(base, spec)
    types = [base[:type], spec[:type]]
    return spec unless types.all?(String) && types.sort == NUMERIC_TYPES

    format = (base[:type] == 'number' ? base : spec)[:format]
    base.delete(:format)
    base[:type] = 'number'
    base[:format] = format if format
    spec.reject { |key, _| [:type, :format].include?(key) }
  end

  def merge_schema_entry!(base, key, value, context)
    if context == :schema && key == :properties && base[key].is_a?(Hash) && value.is_a?(Hash)
      value.each { |name, property| merge_entry!(base[key], name, property, :schema) }
    else
      merge_entry!(base, key, value, child_context(context, key))
    end
  end

  def child_context(context, key)
    return :data if context == :data || DATA_KEYS.include?(key)
    return :schema if context == :schema || SCHEMA_KEYS.include?(key)

    :document
  end

  # When the new spec converts an object to a dictionary (introduces
  # `additionalProperties` on a node that previously had `properties` /
  # `required`), drop the stale fields so the merged result reflects the
  # new intent. We only prune when base does not already declare
  # `additionalProperties`, to preserve manual edits that intentionally
  # combine fixed and dynamic keys.
  def prune_stale_object_fields!(base, spec)
    return unless spec.is_a?(Hash) && spec.key?(:additionalProperties) && !base.key?(:additionalProperties)

    base.delete(:properties)
    base.delete(:required)
  end

  def merge_entry!(base, key, value, context)
    if base[key].is_a?(Hash) && value.is_a?(Hash)
      merge_hash_entry!(base, key, value, context)
    elsif context != :data && base[key].is_a?(Array) && value.is_a?(Array)
      # parameters need to be merged as if `name` and `in` were the Hash keys.
      merge_arrays(base, key, value)
    elsif context == :data || !skip_due_to_additional_properties?(base, key)
      base[key] = value
    end
  end

  def merge_hash_entry!(base, key, value, context)
    return merge_schema!(base[key], value, context: :data) if context == :data

    # Handle example/examples conflict - convert to examples when mixed
    normalize_example_fields!(base[key], value)

    if context == :schema && one_of_needed?(base[key], value)
      merge_one_of!(base[key], value)
    elsif value.key?(:oneOf)
      base[key] = value
    elsif !base[key].key?(:$ref)
      merge_schema!(base[key], value, context: context)
    end
  end

  def one_of_needed?(base, spec)
    return false if base.key?(:$ref)

    spec.key?(:oneOf) || conflicting_types?(base, spec)
  end

  def conflicting_types?(base, spec)
    base[:type].is_a?(String) && spec[:type].is_a?(String) && !same_type?(base[:type], spec[:type])
  end

  def same_type?(first, second)
    first == second || (NUMERIC_TYPES.include?(first) && NUMERIC_TYPES.include?(second))
  end

  def merge_one_of!(base, spec)
    nullable = base.delete(:nullable) || spec[:nullable]
    wrap_in_one_of!(base) unless base[:oneOf]

    one_of_variants(spec).each { |variant| merge_variant!(base, variant) }
    base[:nullable] = true if nullable
    base
  end

  # Annotations describe the whole value, so they stay beside the oneOf. A schema
  # without a type constrains every variant too, and a variant made of it would
  # match every other type, so all of it stays beside the oneOf.
  def wrap_in_one_of!(base)
    base.delete(:oneOf)
    variant = base[:type] ? base.reject { |key, _| annotation?(key) } : {}
    rest = base.reject { |key, _| variant.key?(key) }
    base.replace({ oneOf: [variant].reject(&:empty?) }.merge(rest))
  end

  def annotation?(key)
    ANNOTATION_KEYS.include?(key) || key.start_with?('x-')
  end

  def one_of_variants(schema)
    variants = schema[:oneOf] || [schema.reject { |key, _| key == :nullable }]
    variants.reject { |variant| variant.is_a?(Hash) && variant.empty? }
  end

  # do not ADD `properties` or `required` fields if `additionalProperties` field is present
  def skip_due_to_additional_properties?(base, key)
    base.key?(:additionalProperties) && [:properties, :required].include?(key)
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
    merge_entry!(base_param, :schema, new_param[:schema], :schema) if new_param.key?(:schema)
    merged = base_param.merge(new_param.reject { |key, _| key == :schema })

    # Once a parameter has been seen missing in any earlier test case, keep it optional
    # even if later test cases mark it required again.
    merged = mark_optional_unless_path(merged) if base_param[:required] == false || new_param[:required] == false

    merged
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
    # This writes straight into the document rather than going through
    # KeyTransformer, so symbolize the name here the way symbolize_examples
    # would. Otherwise the next merge sees a string key beside the symbol one
    # the builder produces and treats them as two different examples.
    name = RSpec::OpenAPI::ExampleKey.normalize(hash.delete(:_example_key))&.to_sym || :default
    summary = hash.delete(:_example_summary)
    value = hash.delete(:example)
    example = {}
    example[:summary] = summary if summary
    example[:value] = value
    hash[:examples] = { name => example }
  end

  def merge_variant!(base, spec)
    options = base[:oneOf]
    return if spec[:oneOf] || options.include?(spec)
    return if options.any? { |option| option.is_a?(Hash) && option.key?(:$ref) }

    option = base.key?(:discriminator) ? closest_option(options, spec) : same_type_option(options, spec)
    if option
      merge_schema!(option, spec, context: :schema)
    else
      options.push(spec)
      sort_by_type!(options)
    end
  end

  # A discriminator tells the variants apart by a property, so an object of a new
  # shape is a new variant there. Anywhere else a value could match two variants
  # of one type, so those always merge, into the closest when there are several.
  def same_type_option(options, spec)
    same_type = options.select { |option| option.is_a?(Hash) && same_type?(option[:type], spec[:type]) }
    same_type.max_by { |option| similarity(option, spec) }
  end

  def closest_option(options, spec)
    score, option = options.map { |option| [similarity(option, spec), option] }.max_by(&:first)
    option if score.to_f > SIMILARITY_THRESHOLD
  end

  def sort_by_type!(options)
    options.replace(options.sort_by.with_index { |option, index| [type_name(option), index] })
  end

  def type_name(schema)
    schema.is_a?(Hash) ? schema[:type].to_s : ''
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
