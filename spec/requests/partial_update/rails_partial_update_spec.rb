# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Records one operation over a document that holds several, standing in for a
# run of a subset of specs.
RSpec::OpenAPI.title = 'Partial update'
RSpec::OpenAPI.enable_example = false
RSpec::OpenAPI.path = File.expand_path('../../apps/rails/doc/partial_update/openapi.yaml', __dir__)

RSpec.describe 'partial update', type: :request do
  it 'returns ok' do
    get '/roundtrip', params: { page: '1' }
    expect(response.status).to eq(200)
  end
end
