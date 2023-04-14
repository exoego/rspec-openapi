# frozen_string_literal: true

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
    paths_to_all_fields(obj).select do |key_parts|
      key_parts.size == selector_parts.size && key_parts.zip(selector_parts).all? do |kp, sp|
        kp == sp || (sp == '*' && !kp.nil?)
      end
    end
  end

  def matched_paths_deeply_nested(obj, begin_selector, end_selector)
    path_depth_sizes = paths_to_all_fields(obj).map(&:size).uniq
    path_depth_sizes.map do |depth|
      diff = depth - begin_selector.count('.') - end_selector.count('.')
      if diff >= 0
        selector = "#{begin_selector}.#{'*.' * diff}#{end_selector}"
        matched_paths(obj, selector)
      else
        []
      end
    end.flatten(1)
  end
end
