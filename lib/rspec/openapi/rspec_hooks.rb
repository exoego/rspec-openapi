# frozen_string_literal: true

require 'rspec/core'

RSpec.configuration.before(:each) do |example|
  RSpec::OpenAPI::ExchangeRecorder.reset!(example)
end

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.then { |p| p.is_a?(Proc) ? p.call(example) : p }
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example, extractor: SharedHooks.find_extractor)
    RSpec::OpenAPI.path_records[path] << record if record
  end
end

RSpec.configuration.after(:suite) do
  partial = RSpec::OpenAPI::PartialRun.rspec?
  result_recorder = RSpec::OpenAPI::ResultRecorder.new(RSpec::OpenAPI.path_records, partial: partial)
  result_recorder.record_results!
  reporter = RSpec.configuration.reporter
  if (notice = RSpec::OpenAPI::PartialRun.notice)
    reporter.message notice
  end
  if result_recorder.errors?
    error_message = result_recorder.error_message
    colorizer = RSpec::Core::Formatters::ConsoleCodes
    reporter.message colorizer.wrap(error_message, :failure)
  end
end
