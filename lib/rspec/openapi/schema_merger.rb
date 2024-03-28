# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def merge!(base, spec)
    spec = normalize_keys(spec)
    base = normalize_keys(base)
    merge_schema!(base, spec)
  end

  private

  def normalize_keys(spec)
    case spec
    when Hash
      spec.to_h do |key, value|
        [key.to_s, normalize_keys(value)]
      end
    when Array
      spec.map { |s| normalize_keys(s) }
    else
      spec
    end
  end

  # Not doing `base.replace(deep_merge(base, spec))` to preserve key orders.
  # Also this needs to be aware of OpenAPI details because a Hash-like structure
  # may be an array whose Hash elements have a key name.
  #
  # TODO: Should we probably force-merge `summary` regardless of manual modifications?
  def merge_schema!(base, spec)
    if (options = base['oneOf'])
      merge_closest_match!(options, spec)

      return base
    end

    spec.each do |key, value|
      if base[key].is_a?(Hash) && value.is_a?(Hash)
        merge_schema!(base[key], value) unless base[key].key?('$ref')
      elsif base[key].is_a?(Array) && value.is_a?(Array)
        # parameters need to be merged as if `name` and `in` were the Hash keys.
        merge_arrays(base, key, value)
      else
        # do not ADD `properties` or `required` fields if `additionalProperties` field is present
        base[key] = value unless base.key?('additionalProperties') && %w[properties required].include?(key)
      end
    end
    base
  end

  def merge_arrays(base, key, value)
    base[key] = case key
                when 'parameters'
                  merge_parameters(base, key, value)
                when 'required'
                  # Preserve properties that appears in all test cases
                  value & base[key]
                else
                  # last one wins
                  value
                end
  end

  def merge_parameters(base, key, value)
    all_parameters = value | base[key]

    unique_base_parameters = base[key].index_by { |parameter| [parameter['name'], parameter['in']] }
    all_parameters = all_parameters.map do |parameter|
      base_parameter = unique_base_parameters[[parameter['name'], parameter['in']]] || {}
      base_parameter ? base_parameter.merge(parameter) : parameter
    end

    all_parameters.uniq! { |param| param.slice('name', 'in') }
    base[key] = all_parameters
  end

  SIMILARITY_THRESHOLD = 0.5

  def merge_closest_match!(options, spec)
    score, option = options.map { |option| [similarity(option, spec), option] }.max_by(&:first)

    return if option&.key?('$ref')

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
        return 1 if first.merge(second).key?('$ref')

        intersection = first.keys & second.keys
        total_size = [first.size, second.size].max.to_f

        intersection.sum { |key| similarity(first[key], second[key]) } / total_size
      else
        0
      end

    score.finite? ? score : 0
  end
end
