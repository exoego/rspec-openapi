# frozen_string_literal: true

require 'rspec/openapi/version'
require 'rspec/openapi/components_updater'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/result_recorder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'
require 'rspec/openapi/schema_cleaner'
require 'rspec/openapi/schema_sorter'
require 'rspec/openapi/key_transformer'
require 'rspec/openapi/extractors'
require 'rspec/openapi/extractors/rack'
require 'rspec/openapi/extractors/rails'
require 'rspec/openapi/extractors/hanami'

require 'rspec/openapi/minitest_hooks' if Object.const_defined?('Minitest')
require 'rspec/openapi/rspec_hooks' if ENV['OPENAPI'] && Object.const_defined?('RSpec')

module RSpec::OpenAPI
  @path = 'doc/openapi.yaml'
  @title = File.basename(Dir.pwd)
  @comment = nil
  @enable_example = true
  @description_builder = ->(example) { example.description }
  @summary_builder = ->(example) { example.metadata[:summary] }
  @tags_builder = ->(example) { example.metadata[:tags] }
  @info = {}
  @application_version = '1.0.0'
  @request_headers = []
  @servers = []
  @security_schemes = []
  @example_types = %i[request]
  @response_headers = []
  @path_records = Hash.new { |h, k| h[k] = [] }
  @ignored_path_params = %i[controller action format]
  @ignored_paths = []

  # This is the configuraion override file name we look for within each path.
  @config_filename = 'rspec_openapi.rb'

  class << self
    attr_accessor :path,
                  :title,
                  :comment,
                  :enable_example,
                  :description_builder,
                  :summary_builder,
                  :tags_builder,
                  :info,
                  :application_version,
                  :request_headers,
                  :servers,
                  :security_schemes,
                  :example_types,
                  :response_headers,
                  :path_records,
                  :ignored_paths,
                  :ignored_path_params

    attr_reader   :config_filename
  end
end
