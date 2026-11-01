# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# One of the two spec files of this directory. The outer spec runs it alone,
# with its sibling, or narrowed by a filter, to see which runs remove the
# stale entries of the document.
RSpec::OpenAPI.title = 'Partial update'
RSpec::OpenAPI.enable_example = false
RSpec::OpenAPI.path = File.expand_path('../../apps/rails/doc/partial_update/openapi.yaml', __dir__)

RSpec.describe 'partial update', type: :request do
  it 'returns ok' do
    get '/roundtrip', params: { page: '1' }
    expect(response.status).to eq(200)
  end
end
