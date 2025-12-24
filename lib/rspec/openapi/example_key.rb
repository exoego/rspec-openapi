# frozen_string_literal: true

module RSpec::OpenAPI::ExampleKey
  def self.normalize(value)
    return nil if value.nil?

    value.to_s.downcase.tr(' ', '_')
  end
end
