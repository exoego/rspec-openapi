require 'rspec/openapi/components_updater'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'
require 'rspec/openapi/schema_cleaner'

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
            example = Example.new(self, name, {})
            record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
            RSpec::OpenAPI.path_records[path] << record if record
          end
          result
        end

        def inspect
          self.class.to_s
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
    title = File.basename(Dir.pwd)
    RSpec::OpenAPI.path_records.each do |path, records|
      RSpec::OpenAPI::SchemaFile.new(path).edit do |spec|
        schema = RSpec::OpenAPI::DefaultSchema.build(title)
        schema[:info].merge!(RSpec::OpenAPI.info)
        RSpec::OpenAPI::SchemaMerger.merge!(spec, schema)
        new_from_zero = {}
        records.each do |record|
          begin
            record_schema = RSpec::OpenAPI::SchemaBuilder.build(record)
            RSpec::OpenAPI::SchemaMerger.merge!(spec, record_schema)
            RSpec::OpenAPI::SchemaMerger.merge!(new_from_zero, record_schema)
          rescue StandardError, NotImplementedError => e # e.g. SchemaBuilder raises a NotImplementedError
            RSpec::OpenAPI.error_records[e] = record # Avoid failing the build
          end
        end
        RSpec::OpenAPI::SchemaCleaner.cleanup!(spec, new_from_zero)
        RSpec::OpenAPI::ComponentsUpdater.update!(spec, new_from_zero)
      end
    end
    if RSpec::OpenAPI.error_records.any?
      error_message = <<~EOS
        RSpec::OpenAPI got errors building #{RSpec::OpenAPI.error_records.size} requests

        #{RSpec::OpenAPI.error_records.map {|e, record| "#{e.inspect}: #{record.inspect}" }.join("\n")}
      EOS
      puts error_message
    end
  end
end
