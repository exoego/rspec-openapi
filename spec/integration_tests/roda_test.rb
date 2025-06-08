# frozen_string_literal: true

require_relative '../apps/roda/roda_app'
require 'json'
require 'rack/test'
require 'minitest/autorun'
require 'rspec/openapi'

ENV['OPENAPI_OUTPUT'] ||= 'yaml'

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path("../apps/roda/doc/minitest_openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)
RSpec::OpenAPI.ignored_paths = ['/admin/masters/extensions']

class RodaTest < Minitest::Test
  include Rack::Test::Methods

  i_suck_and_my_tests_are_order_dependent!
  openapi!

  def app
    RodaApp
  end

  def test_when_id_is_given_it_returns_200
    post '/roda', { id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
    assert_equal 200, last_response.status
  end
end
