require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'

  class << self
    attr_accessor :path
  end
end
