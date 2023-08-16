# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require 'minitest/autorun'
require File.expand_path('../rails/config/environment', __dir__)

RSpec::OpenAPI.request_headers = %w[X-Authorization-Token]
RSpec::OpenAPI.response_headers = %w[X-Cursor]
RSpec::OpenAPI.path = File.expand_path("../rails/doc/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)
RSpec::OpenAPI.comment = <<~COMMENT
  This file is auto-generated by rspec-openapi https://github.com/k0kubun/rspec-openapi

  When you write a spec in spec/requests, running the spec with `OPENAPI=1 rspec` will
  update this file automatically. You can also manually edit this file.
COMMENT
RSpec::OpenAPI.servers = [{ url: 'http://localhost:3000' }]
RSpec::OpenAPI.info = {
  description: 'My beautiful API',
  license: {
    name: 'Apache 2.0',
    url: 'https://www.apache.org/licenses/LICENSE-2.0.html',
  },
}

class TablesIndexTest < ActionDispatch::IntegrationTest
  openapi!

  # Patch minitest's ordering of examples to match RSpec's
  # in order to get comparable results
  def self.runnable_methods
    %w[test_with_flat_query_parameters test_with_deep_query_parameters test_with_different_deep_query_parameters
       test_has_a_request_spec_which_does_not_make_any_request test_does_not_return_tables_if_unauthorized]
  end

  def test_with_flat_query_parameters
    get '/tables', params: { page: '1', per: '10' },
                   headers: { authorization: 'k0kubun', 'X-Authorization-Token': 'token' }
    assert_response 200
  end

  def test_with_deep_query_parameters
    get '/tables', params: { filter: { 'name' => 'Example Table' } }, headers: { authorization: 'k0kubun' }
    assert_response 200
  end

  def test_with_different_deep_query_parameters
    get '/tables', params: { filter: { 'price' => 0 } }, headers: { authorization: 'k0kubun' }
    assert_response 200
  end

  def test_has_a_request_spec_which_does_not_make_any_request
    assert true
  end

  def test_does_not_return_tables_if_unauthorized
    get '/tables'
    assert_response 401
  end
end

class TablesShowTest < ActionDispatch::IntegrationTest
  openapi!

  # Patch minitest's ordering of examples to match RSpec's
  # in order to get comparable results
  def self.runnable_methods
    %w[test_returns_a_table test_does_not_return_a_table_if_unauthorized test_does_not_return_a_table_if_not_found]
  end

  def test_does_not_return_a_table_if_unauthorized
    get '/tables/1'
    assert_response 401
  end

  def test_does_not_return_a_table_if_not_found
    get '/tables/2', headers: { authorization: 'k0kubun' }
    assert_response 404
  end

  def test_returns_a_table
    get '/tables/1', headers: { authorization: 'k0kubun' }
    assert_response 200
  end
end

class TablesCreateTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns a table' do
    post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
      name: 'k0kubun',
      description: 'description',
      database_id: 2,
    }.to_json
    assert_response 201
  end
end

class TablesUpdateTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns a table' do
    patch '/tables/1', headers: { authorization: 'k0kubun' }, params: { name: 'test' }
    assert_response 200
  end
end

class TablesDestroyTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns a table' do
    delete '/tables/1', headers: { authorization: 'k0kubun' }
    assert_response 200
  end

  test 'returns no content if specified' do
    delete '/tables/1', headers: { authorization: 'k0kubun' }, params: { no_content: true }
    assert_response 202
  end
end

class ImageTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns a image payload' do
    get '/images/1'
    assert_response 200
  end

  test 'can return an object with an attribute of empty array' do
    get '/images'
    assert_response 200
  end

  test 'returns a image payload with upload' do
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack1('m')
    File.binwrite('test.png', png)
    image = Rack::Test::UploadedFile.new('test.png', 'image/png')
    post '/images/upload', params: { image: image }
    assert_response 200
  end

  test 'returns a image payload with upload nested' do
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack1('m')
    File.binwrite('test.png', png)
    image = Rack::Test::UploadedFile.new('test.png', 'image/png')
    post '/images/upload_nested', params: { nested_image: { image: image, caption: 'Some caption' } }
    assert_response 200
  end

  test 'returns a image payload with upload multiple' do
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack1('m')
    File.binwrite('test.png', png)
    image = Rack::Test::UploadedFile.new('test.png', 'image/png')
    post '/images/upload_multiple', params: { images: [image, image] }
    assert_response 200
  end

  test 'returns a image payload with upload multiple nested' do
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack1('m')
    File.binwrite('test.png', png)
    image = Rack::Test::UploadedFile.new('test.png', 'image/png')
    post '/images/upload_multiple_nested', params: { images: [{ image: image }, { image: image }] }
    assert_response 200
  end
end

class ExtraRoutesTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns the block content' do
    get '/test_block'
    assert_response 200
  end
end

class EngineTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns some content from the engine' do
    get '/my_engine/eng_route'
    assert_response 200
  end
end

class EngineExtraRoutesTest < ActionDispatch::IntegrationTest
  openapi!

  test 'returns the block content' do
    get '/my_engine/test'
    assert_response 200
  end
end
