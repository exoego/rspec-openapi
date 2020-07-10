require_relative '../roda/app'
require 'json'
require 'rack/test'
RSpec::OpenAPI.path = File.expand_path('../roda/doc/openapi.yaml', __dir__)

RSpec.describe 'Roda', type: :request do
  include Rack::Test::Methods

  let(:app) do
    App
  end

  it 'returns 200' do
    post '/roda', { id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(last_response.status).to eq(200)
  end
end
