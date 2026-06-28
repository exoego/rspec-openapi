# frozen_string_literal: true

require 'rspec/openapi/version'
require 'rspec/openapi/components_updater'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/nullable_converter'
require 'rspec/openapi/operation_converter'
require 'rspec/openapi/stream_parser'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/exchange_recorder'
require 'rspec/openapi/result_recorder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/example_key'
require 'rspec/openapi/schema_merger'
require 'rspec/openapi/schema_cleaner'
require 'rspec/openapi/schema_sorter'
require 'rspec/openapi/key_transformer'
require 'rspec/openapi/shared_hooks'
require 'rspec/openapi/extractors'
require 'rspec/openapi/extractors/shared_extractor'
require 'rspec/openapi/extractors/rack'

module RSpec::OpenAPI
  # Streaming media types whose body is a sequence of items, not one document.
  # Their raw body is kept unparsed and split per item (see StreamParser).
  SEQUENTIAL_MEDIA_TYPES = [
    'application/jsonl',
    'application/x-ndjson',
    'application/json-seq',
    'text/event-stream',
  ].freeze

  class Config
    class << self
      attr_accessor :debug_enabled

      def load_environment_settings
        @debug_enabled = ['', '1', 'true'].include?(ENV['DEBUG']&.downcase)
      end
    end
  end

  @path = 'doc/openapi.yaml'
  @title = File.basename(Dir.pwd)
  @comment = nil
  @enable_example = true
  @enable_example_summary = true
  @description_builder = :description.to_proc
  @example_name_builder = :description.to_proc
  @summary_builder = ->(example) { example.metadata[:summary] }
  @tags_builder = ->(example) { example.metadata[:tags] }
  @formats_builder = ->(example) { example.metadata[:formats] }
  @info = {}
  @application_version = '1.0.0'
  @openapi_version = '3.2.0'
  @request_headers = []
  @servers = []
  @security_schemes = []
  @root_tags = []
  @example_types = [:request]
  @response_headers = []
  @path_records = Hash.new { |h, k| h[k] = [] }
  @ignored_path_params = [:controller, :action, :format]
  @ignored_paths = []
  @post_process_hook = nil

  # This is the configuraion override file name we look for within each path.
  @config_filename = 'rspec_openapi.rb'

  class << self
    attr_accessor :path,
                  :title,
                  :comment,
                  :enable_example,
                  :enable_example_summary,
                  :description_builder,
                  :example_name_builder,
                  :summary_builder,
                  :tags_builder,
                  :formats_builder,
                  :info,
                  :application_version,
                  :request_headers,
                  :servers,
                  :security_schemes,
                  :root_tags,
                  :example_types,
                  :response_headers,
                  :path_records,
                  :ignored_paths,
                  :ignored_path_params,
                  :post_process_hook

    attr_reader   :config_filename, :openapi_version

    SUPPORTED_OPENAPI_MAJOR_MINORS = ['3.0', '3.1', '3.2'].freeze

    def openapi_version=(version)
      major_minor = Gem::Version.new(version).segments.first(2).join('.')
      unless SUPPORTED_OPENAPI_MAJOR_MINORS.include?(major_minor)
        raise ArgumentError, "Unsupported OpenAPI version: #{version.inspect}. " \
                             "Supported: #{SUPPORTED_OPENAPI_MAJOR_MINORS.map { |v| "#{v}.x" }.join(', ')}"
      end
      @openapi_version = version
    end

    def openapi_version_at_least?(version)
      Gem::Version.new(openapi_version) >= Gem::Version.new(version)
    end

    # 3.1+ drops `nullable` in favour of JSON Schema null types.
    def json_schema_based?
      openapi_version_at_least?('3.1')
    end

    # 3.2 adds the `query` field and the `additionalOperations` map.
    def supports_additional_operations?
      openapi_version_at_least?('3.2')
    end

    # 3.2 adds `itemSchema` for sequential (streaming) media types.
    def supports_item_schema?
      openapi_version_at_least?('3.2')
    end

    def sequential_media_type?(media_type)
      SEQUENTIAL_MEDIA_TYPES.include?(media_type)
    end

    # Allow Rails request specs to issue extra verbs (e.g. QUERY); ActionDispatch
    # otherwise rejects unknown verbs. No-op outside Rails.
    def register_http_methods(methods)
      # simplecov:disable branch non-Rails guard for roda/hanami; the suite always loads Rails
      return unless defined?(ActionDispatch::Request::HTTP_METHODS)

      # simplecov:enable
      Array(methods).each do |method|
        verb = method.to_s.upcase
        next if ActionDispatch::Request::HTTP_METHODS.include?(verb)

        ActionDispatch::Request::HTTP_METHODS << verb
        ActionDispatch::Request::HTTP_METHOD_LOOKUP[verb] = verb.downcase.to_sym
      end
    end
  end
end

if ENV['OPENAPI']
  RSpec::OpenAPI::Config.load_environment_settings

  begin
    require 'hanami'
  rescue LoadError
    warn 'Hanami not detected' if RSpec::OpenAPI::Config.debug_enabled
  else
    require 'rspec/openapi/extractors/hanami'
  end

  begin
    require 'rails'
  rescue LoadError
    warn 'Rails not detected' if RSpec::OpenAPI::Config.debug_enabled
  else
    require 'rspec/openapi/extractors/rails'
  end
end

require 'rspec/openapi/minitest_hooks' if Object.const_defined?('Minitest')
require 'rspec/openapi/rspec_hooks' if ENV['OPENAPI'] && Object.const_defined?('RSpec')
