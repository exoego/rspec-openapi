# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/multi_request_same_path/error_tmp.yaml', __dir__)

RSpec.describe 'request_pattern error handling', type: :request do
  describe 'GET /widgets/{id}', openapi: { request_pattern: 'not-a-valid-pattern' } do
    it 'fails fast when the pattern cannot be parsed' do
      get '/widgets/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /widgets/{id}', openapi: { request_pattern: 'GET /never/called' } do
    it 'fails fast when no recorded request matches the pattern' do
      get '/widgets/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /widgets/{id}', openapi: { request_pattern: 'GET /widgets/{id}' } do
    it 'fails fast and reports when no request was issued at all' do
      # Intentionally issues no request, so the recorder has nothing to match.
    end
  end
end
