# frozen_string_literal: true

require_relative '../apps/roda/roda_app'
require 'json'
require 'rack/test'

ENV['OPENAPI_OUTPUT'] ||= 'yaml'

RSpec::OpenAPI.openapi_version = '3.0.3'
RSpec::OpenAPI.path = File.expand_path(
  "../apps/roda/doc/request_pattern.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)

RSpec.describe 'Roda request_pattern', type: :request do
  include Rack::Test::Methods

  let(:app) { RodaApp }

  describe 'DELETE /widgets/{id}',
           openapi: { summary: 'Delete a widget', request_pattern: 'DELETE /widgets/{id}' } do
    it 'deletes the widget and verifies it is gone' do
      delete '/widgets/1'
      expect(last_response.status).to eq(200)

      get '/widgets/1?missing=1'
      expect(last_response.status).to eq(404)
    end
  end
end
