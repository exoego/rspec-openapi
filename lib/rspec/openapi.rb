require 'rspec/openapi/version'
require 'rspec/openapi/components_updater'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/result_recorder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'
require 'rspec/openapi/schema_cleaner'

if ENV['OPENAPI']
  require 'rspec/openapi/minitest_hooks'
  require 'rspec/openapi/rspec_hooks'
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
                  :path_records
  end
end
