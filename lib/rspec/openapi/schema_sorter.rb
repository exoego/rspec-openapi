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
      deep_sort_by_selector!(spec, "#{operation}.responses.*.content")
    end
  end

  private

  # @param [Hash] base
  # @param [String] selector
  def deep_sort_by_selector!(base, selector)
    RSpec::OpenAPI::HashHelper.matched_paths(base, selector).each do |paths|
      deep_sort_hash!(base.dig(*paths))
    end
  end

  def deep_sort_hash!(hash)
    sorted = hash.entries.sort_by { |k, _| k.to_s }.to_h.transform_keys(&:to_sym)
    hash.replace(sorted)
  end
end
