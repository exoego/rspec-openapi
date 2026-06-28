# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Exercises the `query` field and `additionalOperations` map. The QUERY verb and
# non-standard-verb routing need Rails 7.1+, so this spec is a no-op below that.
return if Gem::Version.new(Rails::VERSION::STRING) < Gem::Version.new('7.1')

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.openapi_version = '3.2.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/rspec_openapi_3.2_methods.yaml', __dir__)
# GET is already known to ActionDispatch, so it is skipped; QUERY is the verb we
# actually need registered.
RSpec::OpenAPI.register_http_methods(['GET', 'QUERY'])

RSpec.describe 'OpenAPI 3.2 HTTP methods', type: :request do
  it 'records QUERY as the query field with a request body' do
    process(:query, '/aop_search',
            params: { 'q' => 'ruby' }.to_json,
            headers: { 'CONTENT_TYPE' => 'application/json' },)
    expect(response).to have_http_status(:ok)
  end

  it 'records COPY under additionalOperations' do
    process(:copy, '/aop_resource')
    expect(response).to have_http_status(:ok)
  end
end
