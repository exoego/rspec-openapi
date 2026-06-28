# frozen_string_literal: true

# Moves non-standard HTTP methods between the internal flat form
# (`paths.<path>.<method>`) and the 3.2 `additionalOperations` map. 3.2 keeps the
# 8 standard methods plus `query` as fixed fields; other verbs (COPY, MOVE, ...)
# go under `additionalOperations`. normalize! on read, to_additional_operations! on write.
class << RSpec::OpenAPI::OperationConverter = Object.new
  FIXED_METHODS = [:get, :put, :post, :delete, :options, :head, :patch, :trace, :query].freeze
  # Path Item fields that are not operations.
  PATH_ITEM_METADATA = [:summary, :description, :servers, :parameters, :additionalOperations].push(:$ref).freeze

  def to_additional_operations!(spec)
    each_path_item(spec) { |item| relocate_non_standard!(item) }
    spec
  end

  def normalize!(spec)
    each_path_item(spec) { |item| inline_additional_operations!(item) }
    spec
  end

  private

  def relocate_non_standard!(item)
    non_standard = item.keys - FIXED_METHODS - PATH_ITEM_METADATA
    non_standard.each do |method|
      additional = (item[:additionalOperations] ||= {})
      additional[method.to_s.upcase.to_sym] = item.delete(method)
    end
  end

  def inline_additional_operations!(item)
    additional = item.delete(:additionalOperations)
    return unless additional.is_a?(Hash)

    additional.each { |verb, operation| item[verb.to_s.downcase.to_sym] = operation }
  end

  def each_path_item(spec)
    paths = spec[:paths]
    return spec unless paths.is_a?(Hash)

    paths.each_value { |item| yield item if item.is_a?(Hash) }
    spec
  end
end
