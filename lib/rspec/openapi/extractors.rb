# frozen_string_literal: true

# Create namespace
module RSpec::OpenAPI::Extractors
  # @param [String, Symbol] path_parameter
  # @return [Integer, nil]
  def self.number_or_nil(path_parameter)
    Integer(path_parameter.to_s || '')
  rescue ArgumentError
    nil
  end
end
