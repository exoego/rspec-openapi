require 'rspec/openapi/version'

require 'rspec/openapi/minitest' if defined?(Minitest)

if ENV['OPENAPI']
  require 'rspec/openapi/hooks' if defined?(RSpec::Example)
end

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'
  @comment = nil
  @enable_example = true
  @description_builder = -> (example) { example.description }
  @info = {}
  @application_version = '1.0.0'
  @request_headers = []
  @servers = []
  @security_schemes = []
  @example_types = %i[request]
  @response_headers = []
  @path_records = Hash.new { |h, k| h[k] = [] }
  @error_records = {}

  class << self
    attr_accessor :path,
                  :comment,
                  :enable_example,
                  :description_builder,
                  :info,
                  :application_version,
                  :request_headers,
                  :servers,
                  :security_schemes,
                  :example_types,
                  :response_headers,
                  :path_records,
                  :error_records
  end
end
