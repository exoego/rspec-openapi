# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaSorter = Object.new
  # Sort some unpredictably ordered properties in a lexicographical manner to make the order more predictable.
  #
  # @param [Hash|Array]
  def deep_sort!(spec)
    # paths
    deep_sort_by_selector!(spec, 'paths')

    # methods
    deep_sort_by_selector!(spec, 'paths.*')

    # response status code
    deep_sort_by_selector!(spec, 'paths.*.*.responses')

    # content-type
    deep_sort_by_selector!(spec, 'paths.*.*.responses.*.content')
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
    sorted = hash.entries.sort_by { |k, _| k }.to_h
    hash.replace(sorted)
  end
end
