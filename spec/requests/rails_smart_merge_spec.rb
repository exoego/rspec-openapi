# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'json'

require File.expand_path('../rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.request_headers = %w[X-Authorization-Token]
RSpec::OpenAPI.response_headers = %w[X-Cursor]
RSpec::OpenAPI.path = File.expand_path("../rails/doc/smart/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)
RSpec::OpenAPI.comment = <<~COMMENT
  This file is auto-generated by rspec-openapi https://github.com/k0kubun/rspec-openapi

  When you write a spec in spec/requests, running the spec with `OPENAPI=1 rspec` will
  update this file automatically. You can also manually edit this file.
COMMENT
RSpec::OpenAPI.servers = [{ url: 'http://localhost:3000' }]
RSpec::OpenAPI.security_schemes = {
  'Scheme1' => {
    description: 'Authentication scheme',
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'JWT',
  },
}

RSpec::OpenAPI.info = {
  description: 'My beautiful API',
  license: {
    name: 'Apache 2.0',
    url: 'https://www.apache.org/licenses/LICENSE-2.0.html',
  },
}

# Small subset of `rails_spec.rb` with slight changes
RSpec.describe 'Tables', type: :request do
  describe '#index', openapi: { required_request_params: 'show_columns' } do
    context it 'returns a list of tables' do
      it 'with flat query parameters' do
        # These new params replace them in old spec
        get '/tables', params: { page: '42', per: '10', show_columns: true },
                       headers: { authorization: 'k0kubun', 'X-Authorization-Token': 'token' }
        response.set_header('X-Cursor', 100)
        expect(response.status).to eq(200)
      end
    end

    it 'does not return tables if unauthorized' do
      get '/tables'
      expect(response.status).to eq(401)
    end
  end

  describe '#show' do
    it 'returns a table with changes !!!' do
      get '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'Users', type: :request do
  describe '#create' do
    it 'accepts missing avatar_url' do
      post '/users', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'alice',
      }.to_json
      expect(response.status).to eq(201)
    end

    it 'accepts nested object' do
      post '/users', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'alice',
        foo: {
          bar: {
            baz: 42,
          },
        },
      }.to_json
      expect(response.status).to eq(201)
    end

    it 'returns an user' do
      post '/users', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'alice',
        avatar_url: 'https://example.com/avatar.png',
      }.to_json
      expect(response.status).to eq(201)
    end
  end

  describe '#show' do
    it 'returns a user' do
      get '/users/1'
      expect(response.status).to eq(200)
    end

    it 'returns a user whose fields may be missing' do
      get '/users/2'
      expect(response.status).to eq(200)
    end
  end

  describe '#active' do
    it 'returns a boolean' do
      get '/users/1/active'
      expect(response.status).to eq(200)
    end
  end
end
