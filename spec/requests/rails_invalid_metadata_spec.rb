# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# `example_mode` only accepts a Symbol or String naming a mode, or a Hash of
# :request/:response. `read_only` only accepts true, false, or property names.
# Anything else aborts the example with a message naming both the value and
# the example it came from, rather than recording something the user did not
# ask for. The document is never written, so this spec points at a path under
# tmp.
RSpec::OpenAPI.path = File.expand_path('../apps/rails/tmp/invalid_metadata.yaml', __dir__)

RSpec.describe 'invalid metadata', type: :request do
  it 'aborts on a bare value that is not a mode', openapi: { example_mode: 42 } do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end

  # The per-side form is validated separately from the bare one.
  it 'aborts on a per-side value that is not a mode', openapi: { example_mode: { request: 42 } } do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end

  it 'aborts on a read_only value that is not a name', openapi: { read_only: 42 } do
    get '/read_only/plain/1'
    expect(response).to have_http_status(:ok)
  end
end
