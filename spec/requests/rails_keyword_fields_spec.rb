# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path(
  "../apps/rails/doc/keyword_fields/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)
RSpec::OpenAPI.request_headers = ['Secret-Key']
RSpec::OpenAPI.security_schemes = {
  SecretApiKeyAuth: {
    type: 'apiKey',
    in: 'header',
    name: 'Secret-Key',
  },
}

# Bodies whose fields are named like OpenAPI keywords. The cleanup after the
# suite used to read `security`, `parameters`, `properties` and `required`
# wherever they appeared, examples included, so the first body aborted the run
# and the second lost a field. The mere success of this run is part of what the
# outer spec asserts.
RSpec.describe 'fields named like OpenAPI keywords', type: :request do
  describe 'GET /keyword_fields/security', openapi: { security: [{ 'SecretApiKeyAuth' => [] }] } do
    it 'returns a body with security and parameters fields' do
      get '/keyword_fields/security', headers: { 'Secret-Key' => '42' }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /keyword_fields/required', openapi: { example_mode: { response: :multiple } } do
    it 'returns a body with properties and required fields' do
      get '/keyword_fields/required'
      expect(response.status).to eq(200)
    end
  end
end
