class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def reverse_merge!(base, spec)
    spec = normalize_keys(spec)
    deep_reverse_merge!(base, spec)
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

  # Not doing `base.replace(deep_merge(base, spec))` to preserve key orders
  # TODO: Perform more intelligent merges like rerouting edits / merging types
  # Should we probably force-merge `summary` regardless of manual modifications?
  def deep_reverse_merge!(base, spec)
    spec.each do |key, value|
      base_key_value = base[key]
      if base_key_value.is_a?(Hash) && value.is_a?(Hash)
        deep_reverse_merge!(base_key_value, value)
      elsif !base.key?(key)
        base[key] = value
      elsif base_key_value.is_a?(Array) && value.is_a?(Array)
        if key == "parameters"
          # merge arrays
          base[key] |= value
        end
      else
        nil # no-op
      end
    end
    base
  end
end
