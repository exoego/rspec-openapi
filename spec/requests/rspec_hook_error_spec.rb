# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'
require 'fileutils'

openapi_path = ENV.fetch('RSPEC_HOOK_OPENAPI_PATH') do
  File.expand_path('../apps/rails/tmp/rspec_hook_error.yaml', __dir__)
end
FileUtils.mkdir_p(File.dirname(openapi_path))
FileUtils.rm_f(openapi_path)

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = openapi_path
RSpec::OpenAPI.request_headers = []
RSpec::OpenAPI.response_headers = []
RSpec::OpenAPI.path_records.clear

RSpec.describe 'RSpec hooks error handling', type: :request do
  after(:context) do
    path = RSpec::OpenAPI.path
    record = RSpec::OpenAPI.path_records[path].last
    raise 'OpenAPI record was not generated' unless record

    invalid_record = RSpec::OpenAPI::Record.new(**record.to_h.merge(response_body: Object.new))
    RSpec::OpenAPI.path_records[path] << invalid_record
  end

  it 'produces reporter output when schema building fails' do
    get '/invalid_responses'
    expect(response).to have_http_status(:ok)
  end
end
