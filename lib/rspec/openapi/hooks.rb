require 'rspec'
require 'rspec/openapi/default_schema'
require 'rspec/openapi/record_builder'
require 'rspec/openapi/schema_builder'
require 'rspec/openapi/schema_file'
require 'rspec/openapi/schema_merger'

records = []
records_errors = []

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
    records << record if record
  end
end

RSpec.configuration.after(:suite) do
  title = File.basename(Dir.pwd)
  RSpec::OpenAPI::SchemaFile.new(RSpec::OpenAPI.path).edit do |spec|
    RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::DefaultSchema.build(title))
    records.each do |record|
      begin
        RSpec::OpenAPI::SchemaMerger.reverse_merge!(spec, RSpec::OpenAPI::SchemaBuilder.build(record))
      rescue StandardError, NotImplementedError => e # e.g. SchemaBuilder raises a NotImplementedError
        # NOTE: Don't fail the build
        records_errors << [e, record]
      end
    end
  end
  if records_errors.any?
    error_message = <<~EOS
      RSpec::OpenAPI got errors building #{records_errors.size} requests

      #{records_errors.map {|e, record| "#{e.inspect}: #{record.inspect}" }.join("\n")}
    EOS
    colorizer = ::RSpec::Core::Formatters::ConsoleCodes
    RSpec.configuration.reporter.message colorizer.wrap(error_message, :failure)
  end
end
