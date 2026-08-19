# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Controller specs are the other example type rspec-openapi records. They have
# no integration session, so the request and response come off the example
# group itself rather than off ActionDispatch::Integration::Session.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.example_types = [:request, :controller]
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/controller/openapi.yaml', __dir__)

RSpec.describe TablesController, type: :controller do
  it 'records a controller example' do
    request.headers['authorization'] = 'k0kubun'
    get :show, params: { id: 1 }
    expect(response).to have_http_status(:ok)
  end

  it 'ignores an example that issues no request' do
    expect(described_class).to eq(TablesController)
  end
end
