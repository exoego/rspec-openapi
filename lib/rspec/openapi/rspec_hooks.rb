# frozen_string_literal: true

require 'rspec/core'

RSpec.configuration.after(:each) do |example|
  if RSpec::OpenAPI.example_types.include?(example.metadata[:type]) && example.metadata[:openapi] != false
    path = RSpec::OpenAPI.path.then { |p| p.is_a?(Proc) ? p.call(example) : p }
    record = RSpec::OpenAPI::RecordBuilder.build(self, example: example, extractor: find_extractor)
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

def find_extractor
  if Bundler.load.specs.map(&:name).include?('rails') && defined?(Rails) &&
     Rails.respond_to?(:application) && Rails.application
    RSpec::OpenAPI::Extractors::Rails
  elsif Bundler.load.specs.map(&:name).include?('hanami') && defined?(Hanami) &&
        Hanami.respond_to?(:app) && Hanami.app?
    RSpec::OpenAPI::Extractors::Hanami
  # elsif defined?(Roda)
  #   some Roda extractor
  else
    RSpec::OpenAPI::Extractors::Rack
  end
end
