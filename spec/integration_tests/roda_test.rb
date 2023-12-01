# frozen_string_literal: true

require_relative '../roda/roda_app'
require 'json'
require 'rack/test'
require 'minitest/autorun'
require 'rspec/openapi'

ENV['OPENAPI_OUTPUT'] ||= 'yaml'

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path("../roda/doc/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)

class RodaTest < Minitest::Test
  include Rack::Test::Methods

  openapi!

  def app
    RodaApp
  end

  def test_when_id_is_given_it_returns_200
    post '/roda', { id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
    assert_equal 200, last_response.status
  end
end
