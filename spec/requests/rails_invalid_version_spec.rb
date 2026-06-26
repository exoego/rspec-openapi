# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Assigning an unsupported OpenAPI version is rejected at configuration time, so
# this file raises while loading. The integration test runs it in a subprocess
# and asserts the run aborts with the validation message.
RSpec::OpenAPI.openapi_version = '2.0'

RSpec.describe 'unsupported OpenAPI version', type: :request do
  it 'never runs because configuration already raised' do
    get '/stream'
  end
end
