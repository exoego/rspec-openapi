require 'rspec/openapi/version'
require 'rspec/openapi/hooks' if ENV['OPENAPI']

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'
  @comment = nil
  @enable_example = true
  @description_builder = -> (example) { example.description }
  @info = {}
  @application_version = '1.0.0'
  @request_headers = []
  @servers = []
  @example_types = %i[request]
  @response_headers = []

  class << self
    attr_accessor :path,
                  :comment,
                  :enable_example,
                  :description_builder,
                  :info,
                  :application_version,
                  :request_headers,
                  :servers,
                  :example_types,
                  :response_headers
  end
end
