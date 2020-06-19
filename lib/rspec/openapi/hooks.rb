require 'rspec'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'

records = []

RSpec.configuration.after(:each) do |example|
  if example.metadata[:type] == :request && example.metadata[:openapi] != false && request && response
    records << RSpec::OpenAPI::RecordBuilder.build(self, example: example)
  end
end

RSpec.configuration.after(:suite) do
  path = 'doc/openapi.yaml' # TODO: make this configurable
  title = File.basename(Dir.pwd)

  RSpec::OpenAPI::SchemaFile.new(path).edit do |spec|
    RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::DefaultSchema.build(title))
    records.each do |record|
      RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::SchemaBuilder.build(record))
    end
  end
end
