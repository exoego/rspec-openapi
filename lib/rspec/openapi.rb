require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'
  @comment = nil
  @enable_example = true

  class << self
    attr_accessor :path, :comment, :enable_example
  end
end
