# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# `read_only` accepts true, false, or property names. Anything else aborts the
# example with a message naming both the value and the example, rather than
# matching nothing in silence. The document is never written, so this spec
# points at a path under tmp.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/tmp/invalid_read_only.yaml', __dir__)

RSpec.describe 'invalid read_only', type: :request do
  it 'aborts on a value that is not a name', openapi: { read_only: 42 } do
    get '/read_only/plain/1'
    expect(response).to have_http_status(:ok)
  end
end
