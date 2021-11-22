require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'
  @comment = nil
  @enable_example = true
  @description_builder = -> (example) { example.description }
  @application_version = '1.0.0'
  @request_headers = []
  @server_urls = []
  @example_types = %i[request]

  class << self
    attr_accessor :path, :comment, :enable_example, :description_builder, :application_version, :request_headers, :server_urls, :example_types
  end
end
