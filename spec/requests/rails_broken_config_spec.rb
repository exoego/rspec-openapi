# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# The document directory holds a config file that raises on load. rspec-openapi
# should warn about it and still write the document.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/broken_config/openapi.yaml', __dir__)

RSpec.describe 'a broken per-directory config file', type: :request do
  it 'still records the request' do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end
end
