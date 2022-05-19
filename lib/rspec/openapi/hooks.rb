require 'rspec'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'

path_records = Hash.new { |h, k| h[k] = [] }
error_records = {}

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.yield_self { |path| path.is_a?(Proc) ? path.call(example) : path }
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
      records.each do |record|
        begin
          RSpec::OpenAPI::SchemaMerger.merge!(spec, RSpec::OpenAPI::SchemaBuilder.build(record))
        rescue StandardError, NotImplementedError => e # e.g. SchemaBuilder raises a NotImplementedError
          error_records[e] = record # Avoid failing the build
        end
      end
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
