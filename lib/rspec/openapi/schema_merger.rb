class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def merge!(base, spec)
    spec = normalize_keys(spec)
    merge_schema!(base, spec)
  end

  private

  def normalize_keys(spec)
    case spec
    when Hash
      spec.map do |key, value|
        [key.to_s, normalize_keys(value)]
      end.to_h
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
    marker_to_keep_last_duplicate = Time.now.utc.round.to_s
    spec.each do |key, value|
      if base[key].is_a?(Hash) && value.is_a?(Hash)
        if !base[key].key?("$ref")
          merge_schema!(base[key], value)
        end
      elsif base[key].is_a?(Array) && value.is_a?(Array)
        # parameters need to be merged as if `name` and `in` were the Hash keys.
        if key == 'parameters'
          value.each do |param|
            param['__marker'] = marker_to_keep_last_duplicate
          end

          base[key] |= value
          # 9999 is a dummy for old spec.
          dummy = '9999-99-99 99:99:99 UTC'
          base[key]
            .sort_by! { |param| [param['in'], param['name'], param['__marker'] || dummy].join('-') }
            .uniq! { |param| param.slice('name', 'in') }
            .each { |param| param.delete('__marker') }
        else
          base[key] = value
        end
      else
        base[key] = value
      end
    end
    base
  end
end
