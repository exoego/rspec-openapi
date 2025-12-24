# frozen_string_literal: true

# Normalizes example keys for OpenAPI examples field
module RSpec::OpenAPI::ExampleKey
  def self.normalize(value)
    return nil if value.nil?

    value.to_s.downcase.tr(' ', '_')
  end
end
