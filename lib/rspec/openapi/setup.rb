require 'rspec'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'

records = []

RSpec.configuration.after(:each, openapi: true) do |example|
  unless example.pending?
    records << RSpec::OpenAPI::RecordBuilder.build(example, context: self)
  end
end

RSpec.configuration.after(:suite) do
  # TODO: make the path configurable
  RSpec::OpenAPI::SchemaFile.new('doc/openapi.yaml').edit do |spec|
    RSpec::OpenAPI::SchemaMerger.merge!(spec, RSpec::OpenAPI::DefaultSchema)
    records.each do |record|
      RSpec::OpenAPI::SchemaMerger.merge!(spec, RSpec::OpenAPI::SchemaBuilder.build(record))
    end
  end
end
