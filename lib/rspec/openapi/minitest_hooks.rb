# frozen_string_literal: true

require 'minitest'

module RSpec::OpenAPI::Minitest
  Example = Struct.new(:context, :description, :metadata, :file_path)

  # Guards path_records against concurrent appends from Minitest's
  # thread-based parallel executor (parallelize_me!).
  RECORD_MUTEX = Mutex.new

  module RunPatch
    def run(*args)
      result = super
      if ENV['OPENAPI'] && self.class.openapi?
        file_path = method(name).source_location.first
        human_name = name.sub(/^test_/, '').gsub('_', ' ')
        example = Example.new(self, human_name, {}, file_path)
        path = RSpec::OpenAPI.path.then { |p| p.is_a?(Proc) ? p.call(example) : p }
        record = RSpec::OpenAPI::RecordBuilder.build(self, example: example, extractor: SharedHooks.find_extractor)
        if record
          RECORD_MUTEX.synchronize do
            RSpec::OpenAPI::ParallelRecords.schedule_dump!
            RSpec::OpenAPI.path_records[path] << record
          end
        end
      end
      result
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
    RSpec::OpenAPI::ParallelRecords.merge!
    result_recorder = RSpec::OpenAPI::ResultRecorder.new(RSpec::OpenAPI.path_records)
    result_recorder.record_results!
    puts result_recorder.error_message if result_recorder.errors?
  end
end
