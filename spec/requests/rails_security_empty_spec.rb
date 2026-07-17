# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path(
  "../apps/rails/doc/security_empty/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)
RSpec::OpenAPI.request_headers = ['Secret-Key', 'X-Api-Token']
RSpec::OpenAPI.security_schemes = {
  SecretApiKeyAuth: {
    type: 'apiKey',
    in: 'header',
    name: 'Secret-Key',
  },
  OtherApiKeyAuth: {
    type: 'apiKey',
    in: 'header',
    name: 'X-Api-Token',
  },
}

# Regression for the `security: []` opt-out: the after(:suite) cleanup used to
# crash with NoMethodError on such operations, so the mere success of this run
# is part of what the outer spec asserts.
RSpec.describe 'public operation opting out with security: []', type: :request do
  describe 'GET /widgets/{id}', openapi: { security: [] } do
    it 'returns the widget without authentication' do
      get '/widgets/1', headers: { 'Secret-Key' => 'ignored-by-public-endpoint' }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'operation secured by the scheme', type: :request do
  describe 'GET /secret_items', openapi: { security: [{ 'SecretApiKeyAuth' => [] }] } do
    it 'authorizes with secret key' do
      get '/secret_items', headers: { 'Secret-Key' => '42' }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'operation secured by another scheme', type: :request do
  describe 'GET /test_block', openapi: { security: [{ 'OtherApiKeyAuth' => [] }] } do
    it 'authorizes with the other scheme' do
      get '/test_block', headers: { 'Secret-Key' => '42', 'X-Api-Token' => 'token' }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'operation without security metadata', type: :request do
  describe 'GET /orgs/{org_id}/members/{user_id}' do
    it 'returns the member' do
      get '/orgs/acme/members/42', headers: { 'Secret-Key' => '42' }
      expect(response.status).to eq(200)
    end
  end
end
