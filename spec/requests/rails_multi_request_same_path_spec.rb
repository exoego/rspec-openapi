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
  describe 'GET /widgets/{id}', openapi: { summary: 'Get a widget' } do
    it 'returns the widget' do
      get '/widgets/1'
      expect(response.status).to eq(200)
    end

    it 'returns 404 when missing' do
      get '/widgets/1?missing=1'
      expect(response.status).to eq(404)
    end
  end

  describe 'DELETE /widgets/{id}',
           openapi: { summary: 'Delete a widget', request_pattern: 'DELETE /widgets/{id}' } do
    it 'deletes the widget and verifies it is gone' do
      delete '/widgets/1'
      expect(response.status).to eq(200)

      get '/widgets/1?missing=1'
      expect(response.status).to eq(404)
    end
  end

  describe 'GET /orgs/{org_id}/members/{user_id}', openapi: { summary: 'Get an org member' } do
    it 'returns the member' do
      get '/orgs/acme/members/42'
      expect(response.status).to eq(200)
    end

    it 'returns 404 when missing' do
      get '/orgs/acme/members/42?missing=1'
      expect(response.status).to eq(404)
    end
  end

  describe 'DELETE /orgs/{org_id}/members/{user_id}',
           openapi: {
             summary: 'Remove an org member',
             request_pattern: 'DELETE /orgs/{org_id}/members/{user_id}',
           } do
    it 'removes the member and verifies it is gone' do
      delete '/orgs/acme/members/42'
      expect(response.status).to eq(200)

      get '/orgs/acme/members/42?missing=1'
      expect(response.status).to eq(404)
    end
  end
end
