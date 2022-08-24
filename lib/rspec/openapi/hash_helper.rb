class << RSpec::OpenAPI::HashHelper = Object.new
  def paths_to_all_fields(obj)
    case obj
    when Hash
      obj.each.flat_map do |k, v|
        k = k.to_s
        [[k]] + paths_to_all_fields(v).map { |x| [k, *x] }
      end
    else
      []
    end
  end

  def matched_paths(obj, selector)
    selector_parts = selector.split('.').map(&:to_s)
    selectors = paths_to_all_fields(obj).select do |key_parts|
      key_parts.size == selector_parts.size && key_parts.zip(selector_parts).all? do |kp, sp|
        kp == sp || (sp == '*' && kp != nil)
      end
    end
    selectors
  end
end
