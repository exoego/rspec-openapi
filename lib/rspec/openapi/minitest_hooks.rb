require 'minitest'

module RSpec
  module OpenAPI
    module Minitest
      class Example < Struct.new(:context, :description, :metadata) ; end

      module TestPatch
        def self.prepended(base)
          base.extend(ClassMethods)
        end

        def run(*args)
          result = super
          if ENV['OPENAPI'] && self.class.openapi?
            path = RSpec::OpenAPI.path.yield_self { |p| p.is_a?(Proc) ? p.call(example) : p }
            human_name = name.sub(/^test_/, "").gsub(/_/, " ")
            example = Example.new(self, human_name, {})
            record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
            RSpec::OpenAPI.path_records[path] << record if record
          end
          result
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
  end
end

Minitest::Test.prepend RSpec::OpenAPI::Minitest::TestPatch

Minitest.after_run do
  if ENV['OPENAPI']
    result_recorder = RSpec::OpenAPI::ResultRecorder.new(RSpec::OpenAPI.path_records)
    result_recorder.record_results!
    puts result_record.error_message if result_recorder.errors?
  end
end
