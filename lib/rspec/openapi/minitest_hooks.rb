# frozen_string_literal: true

require 'minitest'

module RSpec::OpenAPI::Minitest
  Example = Struct.new(:context, :description, :metadata, :file_path)

  module RunPatch
    def run(*args)
      result = super
      if ENV['OPENAPI'] && self.class.openapi?
        file_path = method(name).source_location.first
        human_name = name.sub(/^test_/, '').gsub('_', ' ')
        example = Example.new(self, human_name, {}, file_path)
        path = RSpec::OpenAPI.path.then { |p| p.is_a?(Proc) ? p.call(example) : p }
        record = RSpec::OpenAPI::RecordBuilder.build(self, example: example, extractor: find_extractor)
        RSpec::OpenAPI.path_records[path] << record if record
      end
      result
    end

    def find_extractor
      names = Bundler.load.specs.map(&:name)

      if names.include?('rails') && defined?(Rails) &&
         Rails.respond_to?(:application) && Rails.application
        RSpec::OpenAPI::Extractors::Rails
      elsif names.include?('hanami') && defined?(Hanami) &&
            Hanami.respond_to?(:app) && Hanami.app?
        RSpec::OpenAPI::Extractors::Hanami
        # elsif defined?(Roda)
        #   some Roda extractor
      else
        RSpec::OpenAPI::Extractors::Rack
      end
    end
  end

  module ActivateOpenApiClassMethods
    def self.prepended(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def openapi?
        @openapi
      end

      def openapi!
        @openapi = true
      end
    end
  end
end

Minitest::Test.prepend RSpec::OpenAPI::Minitest::ActivateOpenApiClassMethods

if ENV['OPENAPI']
  Minitest::Test.prepend RSpec::OpenAPI::Minitest::RunPatch

  Minitest.after_run do
    result_recorder = RSpec::OpenAPI::ResultRecorder.new(RSpec::OpenAPI.path_records)
    result_recorder.record_results!
    puts result_recorder.error_message if result_recorder.errors?
  end
end
