# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Re-records over a hand-edited 3.2 document. The untouched entries exercise the
# read-side normalization: /legacy carries JSON-Schema null type arrays, and
# /weird_non_hash is a non-object path item the converters must skip. Both are
# dropped from the output (as any un-recorded path is).
RSpec::OpenAPI.title = 'Round-trip'
RSpec::OpenAPI.openapi_version = '3.2.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/roundtrip/input.yaml', __dir__)

RSpec.describe 'OpenAPI 3.2 hand-edited document round-trip', type: :request do
  it 'records the touched path and preserves the hand-edited one' do
    get '/roundtrip'
    expect(response).to have_http_status(:ok)
  end
end
