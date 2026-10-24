# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Re-records over a document holding an alias to an anchor it never defines.
# Reading hands it to YAML.safe_load, which rejects every alias, so the run
# aborts and the document is left as it was.
RSpec::OpenAPI.title = 'Dangling alias'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/dangling_alias/openapi.yaml', __dir__)

RSpec.describe 'a document with a dangling alias', type: :request do
  it 'records the request before the document is read' do
    get '/example_mode_single'
    expect(response).to have_http_status(:ok)
  end
end
