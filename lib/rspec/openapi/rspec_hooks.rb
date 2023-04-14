# frozen_string_literal: true

require 'rspec/core'

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.yield_self { |p| p.is_a?(Proc) ? p.call(example) : p }
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
    RSpec::OpenAPI.path_records[path] << record if record
  end
end

RSpec.configuration.after(:suite) do
  result_recorder = RSpec::OpenAPI::ResultRecorder.new(RSpec::OpenAPI.path_records)
  result_recorder.record_results!
  if result_recorder.errors?
    error_message = result_recorder.error_message
    colorizer = RSpec::Core::Formatters::ConsoleCodes
    RSpec.configuration.reporter.message colorizer.wrap(error_message, :failure)
  end
end
