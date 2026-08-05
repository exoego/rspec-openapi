# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# `example_mode` only accepts a Symbol or String naming a mode, or a Hash of
# :request/:response. Anything else aborts the example with a message naming
# both the value and the example it came from, rather than recording something
# the user did not ask for. The document is never written, so this spec points
# at a path under tmp.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/tmp/invalid_example_mode.yaml', __dir__)

RSpec.describe 'invalid example_mode', type: :request do
  it 'aborts the example', openapi: { example_mode: 42 } do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end
end
