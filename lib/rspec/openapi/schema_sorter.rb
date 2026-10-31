# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaSorter = Object.new
  # Sort some unpredictably ordered properties in a lexicographical manner to make the order more predictable.
  #
  # @param [Hash|Array]
  # Operation containers: fixed methods sit directly under the path item, while
  # 3.2 puts non-standard verbs (COPY, MOVE, ...) one level deeper, under
  # `additionalOperations`. Both need the same response/content sorting, or their
  # order follows RSpec's random execution order and produces churny diffs.
  OPERATION_SELECTORS = ['paths.*.*', 'paths.*.additionalOperations.*'].freeze

  def deep_sort!(spec)
    # paths
    deep_sort_by_selector!(spec, 'paths')

    # methods (and the additionalOperations verb map)
    deep_sort_by_selector!(spec, 'paths.*')
    deep_sort_by_selector!(spec, 'paths.*.additionalOperations')

    OPERATION_SELECTORS.each do |operation|
      # response status code
      deep_sort_by_selector!(spec, "#{operation}.responses")

      # content-type
      deep_sort_by_selector!(spec, "#{operation}.requestBody.content")
      deep_sort_by_selector!(spec, "#{operation}.responses.*.content")

      # named examples (keyed by test description)
      deep_sort_by_selector!(spec, "#{operation}.requestBody.content.*.examples")
      deep_sort_by_selector!(spec, "#{operation}.responses.*.content.*.examples")
    end
  end

  private

  # @param [Hash] base
  # @param [String] selector
  def deep_sort_by_selector!(base, selector)
    RSpec::OpenAPI::HashHelper.each_matched(base, nil, selector) do |_parent, _key, hash, _counterpart|
      deep_sort_hash!(hash)
    end
  end

  # Re-inserting a key moves it to the end, so re-inserting every key in sorted
  # order sorts the hash in place. A document read back from a file is sorted
  # already, so a hash whose keys are in order is left alone. The keys are all
  # symbols, which sort as their names do.
  def deep_sort_hash!(hash)
    keys = hash.keys
    sorted = keys.sort
    return if sorted == keys

    sorted.each { |key| hash[key] = hash.delete(key) }
  end
end
