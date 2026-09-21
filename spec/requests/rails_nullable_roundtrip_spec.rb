# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Re-records the 200 over a document whose untouched 409 response carries a
# hand-written multi-type nullable schema. Reading normalizes `type: [string,
# integer, "null"]` to the internal `nullable` form, and writing converts it
# back, so the regenerated document shows whether the type array stays flat
# (#451).
RSpec::OpenAPI.title = 'Nullable round-trip'
RSpec::OpenAPI.openapi_version = '3.2.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/nullable_roundtrip/input.yaml', __dir__)

RSpec.describe 'hand-edited multi-type nullable schema round-trip', type: :request do
  it 'records the 200 and rewrites the 409 schema flat' do
    get '/nullable_roundtrip'
    expect(response).to have_http_status(:ok)
  end
end
