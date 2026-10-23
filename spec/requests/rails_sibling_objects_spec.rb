# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.title = 'Sibling objects'
RSpec::OpenAPI.openapi_version = '3.1.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/sibling_objects/openapi.yaml', __dir__)

RSpec.describe 'objects merged across sibling array items', type: :request do
  it 'keeps a oneOf dictionary schema on every sibling', openapi: {
    additional_properties: { 'products.meta' => { oneOf: [{ type: 'string' }, { type: 'integer' }] } },
  } do
    get '/sibling_objects/dictionary'
    expect(response).to have_http_status(:ok)
  end

  it 'keeps the shared required keys of a hybrid object', openapi: {
    hybrid_additional_properties: { 'products.meta' => { type: 'string' } },
  } do
    get '/sibling_objects/hybrid'
    expect(response).to have_http_status(:ok)
  end

  it 'keeps every keyword of a dictionary override', openapi: {
    additional_properties: {
      'products.meta' => {
        type: 'object', description: 'per-locale labels',
        properties: { label: { type: 'string', description: 'shown in the menu' } }, required: ['label'],
      },
    },
  } do
    get '/sibling_objects/described'
    expect(response).to have_http_status(:ok)
  end

  it 'ignores an empty additionalProperties override', openapi: {
    additional_properties: { 'products.meta' => {} },
  } do
    get '/sibling_objects/empty_override'
    expect(response).to have_http_status(:ok)
  end

  describe 'properties named default and enum' do
    it 'records text options, some blank' do
      get '/sibling_objects/settings'
      expect(response).to have_http_status(:ok)
    end

    it 'records flag options' do
      get '/sibling_objects/settings', params: { flags: '1' }
      expect(response).to have_http_status(:ok)
    end
  end
end
