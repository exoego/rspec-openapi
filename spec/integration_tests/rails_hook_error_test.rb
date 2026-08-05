# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require 'fileutils'
require 'minitest/autorun'
require File.expand_path('../apps/rails/config/environment', __dir__)

OPENAPI_PATH = File.expand_path('../apps/rails/tmp/minitest_hook_error.yaml', __dir__)
FileUtils.mkdir_p(File.dirname(OPENAPI_PATH))
FileUtils.rm_f(OPENAPI_PATH)

# `path` takes a proc resolved per example under Minitest too, not only RSpec.
RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = ->(_example) { OPENAPI_PATH }
RSpec::OpenAPI.request_headers = []
RSpec::OpenAPI.response_headers = []

class MinitestHookErrorTest < ActionDispatch::IntegrationTest
  openapi!

  test 'records a request whose schema is then made unbuildable' do
    get '/invalid_responses'
    assert_response 200
  end
end

# after_run blocks run in reverse registration order, so this one runs before
# the recorder rspec-openapi registered while it was loading. It swaps in a
# response body the schema builder cannot handle, which is what makes the
# recorder report an error rather than write a document.
Minitest.after_run do
  record = RSpec::OpenAPI.path_records[OPENAPI_PATH].last
  raise 'OpenAPI record was not generated' unless record

  RSpec::OpenAPI.path_records[OPENAPI_PATH] << RSpec::OpenAPI::Record.new(
    **record.to_h, response_body: Object.new,
  )
end
