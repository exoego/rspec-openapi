require 'rspec'
require 'rspec/openapi/components_updater'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'
require 'rspec/openapi/schema_cleaner'

path_records = Hash.new { |h, k| h[k] = [] }
error_records = {}

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.yield_self { |p| p.is_a?(Proc) ? p.call(example) : p }
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
    path_records[path] << record if record
  end
end

RSpec.configuration.after(:suite) do
  title = File.basename(Dir.pwd)
  path_records.each do |path, records|
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
          error_records[e] = record # Avoid failing the build
        end
      end
      RSpec::OpenAPI::SchemaCleaner.cleanup!(spec, new_from_zero)
      RSpec::OpenAPI::ComponentsUpdater.update!(spec, new_from_zero)
    end
  end
  if error_records.any?
    error_message = <<~EOS
      RSpec::OpenAPI got errors building #{error_records.size} requests

      #{error_records.map {|e, record| "#{e.inspect}: #{record.inspect}" }.join("\n")}
    EOS
    colorizer = ::RSpec::Core::Formatters::ConsoleCodes
    RSpec.configuration.reporter.message colorizer.wrap(error_message, :failure)
  end
end
