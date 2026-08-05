# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Exercises the settings that accept something other than a plain value:
# `title` and `path` may be procs resolved per example, `post_process_hook`
# gets the last word on the built document, and a `comment` without a trailing
# newline has to be terminated before it is turned into YAML comment lines.
# `enable_example_summary` is off here so summaries are left out of `examples`.
RSpec::OpenAPI.title = ->(example) { "OpenAPI Documentation for #{example.metadata[:type]}" }
RSpec::OpenAPI.path = lambda { |_example|
  File.expand_path('../apps/rails/doc/config/openapi.yaml', __dir__)
}
RSpec::OpenAPI.comment = 'This file is auto-generated. Edits are preserved where possible.'
RSpec::OpenAPI.enable_example_summary = false
RSpec::OpenAPI.post_process_hook = lambda { |_path, records, spec|
  spec[:info][:'x-request-count'] = records.size
}

RSpec.describe 'configuration accepting procs and hooks', type: :request do
  it 'records a response in :multiple example mode', openapi: { example_mode: :multiple } do
    get '/example_mode_multiple'
    expect(response).to have_http_status(:ok)
  end

  it 'records a table with path and query parameters' do
    get '/tables/1', params: { page: 1 }, headers: { authorization: 'k0kubun' }
    expect(response).to have_http_status(:ok)
  end
end
