# frozen_string_literal: true

class << RSpec::OpenAPI::HashHelper = Object.new
  def paths_to_all_fields(obj)
    case obj
    when Hash
      obj.each.flat_map do |k, v|
        k = k.to_sym
        [[k]] + paths_to_all_fields(v).map { |x| [k, *x] }
      end
    when Array
      obj.flat_map.with_index do |value, i|
        [[i]] + paths_to_all_fields(value).map { |x| [i, *x] }
      end
    else
      []
    end
  end

  # Paths in obj matching a dot separated selector, where `*` is any one key or
  # array index. Only paths of exactly the selector's length can match, so this
  # descends the branches that still match rather than listing every path in the
  # document and filtering. A document built from a large suite holds tens of
  # thousands of nodes and these selectors run dozens of times per build.
  def matched_paths(obj, selector)
    selector_parts = selector.split('.').map(&:to_sym)
    return [] if selector_parts.empty?

    matches = []
    collect_matches(obj, selector_parts, 0, [], matches)
    matches
  end

  def matched_paths_deeply_nested(obj, begin_selector, end_selector)
    begin_depth = begin_selector.is_a?(Symbol) ? 0 : begin_selector.count('.')
    end_depth = end_selector.is_a?(Symbol) ? 0 : end_selector.count('.')

    # Every path in obj has all of its prefixes in obj too, so the depths that
    # occur are exactly 1 up to the deepest one.
    (1..max_depth(obj)).flat_map do |depth|
      gap = depth - begin_depth - end_depth
      next [] if gap.negative?

      matched_paths(obj, "#{begin_selector}.#{'*.' * gap}#{end_selector}")
    end
  end

  private

  def collect_matches(obj, selector_parts, depth, prefix, matches)
    part = selector_parts[depth]
    last = depth == selector_parts.size - 1

    each_child(obj) do |key, value|
      next unless part == :* || part == key

      path = [*prefix, key]
      if last
        matches << path
      else
        collect_matches(value, selector_parts, depth + 1, path, matches)
      end
    end
  end

  def each_child(obj)
    case obj
    when Hash then obj.each { |key, value| yield key.to_sym, value }
    when Array then obj.each_with_index { |value, index| yield index, value }
    end
  end

  def max_depth(obj)
    case obj
    when Hash then obj.empty? ? 0 : 1 + obj.each_value.map { |value| max_depth(value) }.max
    when Array then obj.empty? ? 0 : 1 + obj.map { |value| max_depth(value) }.max
    else 0
    end
  end
end
