# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path(
  "../apps/rails/doc/smart_envelope/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)

# An API that wraps every body in an envelope. The resource inside the envelope
# is what gets replaced with a $ref, so no body is ever a $ref by itself.
RSpec.describe 'Rooms', type: :request do
  describe 'GET /rooms' do
    it 'returns rooms in an envelope' do
      get '/rooms'
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /rooms/{id}' do
    it 'returns a room in an envelope' do
      get '/rooms/1'
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /rooms' do
    it 'creates a room from an envelope' do
      post '/rooms', headers: { 'Content-Type': 'application/json' }, params: {
        room: { name: 'Kitchen', area: 12.5 },
      }.to_json
      expect(response.status).to eq(201)
    end
  end
end
