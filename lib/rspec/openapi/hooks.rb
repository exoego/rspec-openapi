require 'rspec'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'

records = []

RSpec.configuration.after(:each) do |example|
  if example.metadata[:type] == :request && example.metadata[:openapi] != false
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
    records << record if record
  end
end

RSpec.configuration.after(:suite) do
  title = File.basename(Dir.pwd)
  RSpec::OpenAPI::SchemaFile.new(RSpec::OpenAPI.path).edit do |spec|
    RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::DefaultSchema.build(title))
    records.each do |record|
      RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::SchemaBuilder.build(record))
    end
  end
end
