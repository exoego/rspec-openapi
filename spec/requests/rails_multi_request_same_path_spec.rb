# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path(
  "../apps/rails/doc/multi_request_same_path/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)

RSpec.describe 'multi-request same path regression', type: :request do
  describe 'GET /multi_request_same_path', openapi: { summary: 'Get multi request resource' } do
    it 'returns resource details' do
      get '/multi_request_same_path'
      expect(response.status).to eq(200)
    end

    it 'returns 404 when missing=true' do
      get '/multi_request_same_path?missing=1'
      expect(response.status).to eq(404)
    end
  end

  describe 'DELETE /multi_request_same_path', openapi: { summary: 'Delete multi request resource' } do
    it 'deletes resource and verifies it is gone with a follow-up GET' do
      delete '/multi_request_same_path'
      expect(response.status).to eq(200)

      # This second request must NOT be used for operation metadata extraction.
      get '/multi_request_same_path?missing=1'
      expect(response.status).to eq(404)
    end
  end
end
