require_relative '../roda/roda_app'
require 'json'
require 'rack/test'
require 'rspec/openapi'
require 'minitest/autorun'

ENV['OPENAPI_OUTPUT'] ||= 'yaml'

RSpec::OpenAPI.path = File.expand_path("../roda/doc/openapi.#{ENV['OPENAPI_OUTPUT']}", __dir__)

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
