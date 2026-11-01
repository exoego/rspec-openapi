# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# The sibling of rails_partial_update_spec.rb. A run that names that file
# alone leaves this one out, which makes the run partial.
RSpec::OpenAPI.title = 'Partial update'
RSpec::OpenAPI.enable_example = false
RSpec::OpenAPI.path = File.expand_path('../../apps/rails/doc/partial_update/openapi.yaml', __dir__)

RSpec.describe 'partial update sibling', type: :request do
  it 'returns status' do
    get '/description_preserve_test'
    expect(response.status).to eq(200)
  end
end
