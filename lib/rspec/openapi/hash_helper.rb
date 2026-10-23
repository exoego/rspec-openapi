# frozen_string_literal: true

class << RSpec::OpenAPI::HashHelper = Object.new
  # Paths in obj matching a dot separated selector, where `*` is any one key or
  # array index. Only paths of exactly the selector's length can match, so this
  # descends the branches that still match rather than listing every path in the
  # document and filtering. A document built from a large suite holds tens of
  # thousands of nodes and these selectors run dozens of times per build.
  def matched_paths(obj, selector)
    matches = []
    collect_matches(obj, split_selector(selector), 0, [], matches)
    matches
  end

  # Paths that start with a match of begin_selector and end with a match of an
  # end selector, with any number of keys in between: the matches of the first
  # end selector sorted by length, then those of the next, each length in
  # document order.
  #
  # The subtree under a begin match is walked once for all the end selectors,
  # checking the tail of every path against each. Walking it once per possible
  # length instead makes this cost the depth of the document times its size.
  def matched_paths_deeply_nested(obj, begin_selector, *end_selectors)
    end_parts = end_selectors.map { |selector| split_selector(selector) }
    matches = end_parts.map { [] }
    matched_paths(obj, begin_selector).each do |prefix|
      collect_suffix_matches(obj.dig(*prefix), end_parts, prefix.dup, prefix.size, matches)
    end
    matches.flat_map { |found| found.group_by(&:size).sort_by(&:first).flat_map(&:last) }
  end

  # Keys whose values hold user data, not schemas. Their contents must never be
  # rewritten, or a recorded example/default that happens to contain a field
  # named `type` or `nullable` would be silently mangled.
  DATA_KEYS = [:example, :examples, :default, :enum, :const].freeze

  # Yields every hash in obj outside the data subtrees in DATA_KEYS, each after
  # its descendants. The entries of a `properties` map are schemas whatever
  # their names, so the map itself is skipped and each entry is yielded.
  def each_schema(obj, &block)
    case obj
    when Hash
      obj.each do |key, value|
        if key == :properties && value.is_a?(Hash)
          value.each_value { |property| each_schema(property, &block) }
        elsif !DATA_KEYS.include?(key)
          each_schema(value, &block)
        end
      end
      yield obj
    when Array
      obj.each { |value| each_schema(value, &block) }
    end
  end

  # The variant of a schema that has the type, where a schema without a oneOf
  # is its only variant.
  def variant_of_type(schema, type)
    (schema[:oneOf] || [schema]).find { |variant| variant.is_a?(Hash) && variant[:type] == type }
  end

  private

  def split_selector(selector)
    selector.split('.').map(&:to_sym)
  end

  # `path` is the stack of keys from the root to obj, pushed and popped in
  # place, so a path is only ever copied for a match.
  def collect_matches(obj, selector_parts, depth, path, matches)
    part = selector_parts[depth]
    last = depth == selector_parts.size - 1

    each_child(obj) do |key, value|
      next unless part == :* || part == key

      path.push(key)
      if last
        matches << path.dup
      else
        collect_matches(value, selector_parts, depth + 1, path, matches)
      end
      path.pop
    end
  end

  # The loops below run once per node of the document, so they index by hand:
  # each_with_index and Integer#times allocate per call.
  def collect_suffix_matches(obj, end_parts, path, prefix_size, matches)
    each_child(obj) do |key, value|
      path.push(key)
      index = 0
      while index < end_parts.size
        parts = end_parts[index]
        matches[index] << path.dup if path.size >= prefix_size + parts.size && suffix_matches?(path, parts)
        index += 1
      end
      collect_suffix_matches(value, end_parts, path, prefix_size, matches)
      path.pop
    end
  end

  def suffix_matches?(path, parts)
    offset = path.size - parts.size
    index = 0
    while index < parts.size
      part = parts[index]
      return false unless part == :* || part == path[offset + index]

      index += 1
    end
    true
  end

  def each_child(obj)
    case obj
    when Hash
      obj.each { |key, value| yield key.to_sym, value }
    when Array
      index = 0
      obj.each do |value|
        yield index, value
        index += 1
      end
    end
  end
end
