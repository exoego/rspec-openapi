require 'rspec'

path_records = Hash.new { |h, k| h[k] = [] }

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.yield_self { |p| p.is_a?(Proc) ? p.call(example) : p }
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example)
    path_records[path] << record if record
  end
end

RSpec.configuration.after(:suite) do
  result_recorder = RSpec::OpenAPI::ResultRecorder.new(path_records)
  result_recorder.record_results!
  if result_recorder.errors?
    error_message = result_recorder.error_message
    colorizer = ::RSpec::Core::Formatters::ConsoleCodes
    RSpec.configuration.reporter.message colorizer.wrap(error_message, :failure)
  end
end
