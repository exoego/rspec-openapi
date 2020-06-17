class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def reverse_merge!(base, spec)
    spec = normalize_keys(spec)
    base.replace(deep_merge(spec, base))
  end

  private

  def normalize_keys(spec)
    if spec.is_a?(Hash)
      spec.map do |key, value|
        [key.to_s, normalize_keys(value)]
      end.to_h
    else
      spec
    end
  end

  # TODO: Perform more intelligent merges like rerouting edits / merging types
  def deep_merge(base, spec)
    spec.each do |key, value|
      if base[key].is_a?(Hash) && value.is_a?(Hash)
        base[key] = deep_merge(base[key], value)
      else
        base[key] = value
      end
    end
    base
  end
end
