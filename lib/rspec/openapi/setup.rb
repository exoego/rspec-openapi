require 'rspec'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/record_registry'

RSpec.configuration.after(:each, openapi: true) do |example|
  record = RSpec::OpenAPI::RecordBuilder.build(example)
  RSpec::OpenAPI::RecordRegistry.add(record)
end
