# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# With `enable_example` off, nothing recorded carries a sample value: neither
# the parameters nor the request body get an `example`, only their schemas.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.enable_example = false
RSpec::OpenAPI.request_headers = ['X-Authorization-Token']
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/no_example/openapi.yaml', __dir__)

RSpec.describe 'documents without examples', type: :request do
  it 'records path and query parameters without example values' do
    get '/tables/1', params: { page: 1 }, headers: { authorization: 'k0kubun', 'X-Authorization-Token': 'token' }
    expect(response).to have_http_status(:ok)
  end

  it 'records a request body without an example value' do
    post '/tables', params: { name: 'Table', description: 'A table' },
                    headers: { authorization: 'k0kubun' }, as: :json
    expect(response).to have_http_status(:created)
  end
end
