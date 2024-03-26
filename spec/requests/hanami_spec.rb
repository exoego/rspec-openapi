# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['HANAMI_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require "hanami"

module Hanami
  def self.app_path(dir = Hanami.app_path(File.expand_path('../apps/hanami/', __dir__)))
    dir = Pathname(dir).expand_path
    path = dir.join(APP_PATH)

    if path.file?
      path
    elsif !dir.root?
      app_path(dir.parent)
    end
  end
end
# SPEC_ROOT = File.expand_path('../apps/hanami', __dir__).freeze

require "hanami/prepare"

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.request_headers = %w[X-Authorization-Token Secret-Key]
RSpec::OpenAPI.response_headers = %w[X-Cursor]
RSpec::OpenAPI.path = File.expand_path("../apps/rails/doc/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)
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

RSpec::OpenAPI.security_schemes = {
  SecretApiKeyAuth: {
    type: 'apiKey',
    in: 'header',
    name: 'Secret-Key',
  },
}

RSpec.xdescribe 'Tables', type: :request do
  describe '#index' do
    context it 'returns a list of tables' do
      it 'with flat query parameters' do
        get '/tables', params: { page: '1', per: '10' },
                       headers: { authorization: 'k0kubun', 'X-Authorization-Token': 'token' }
        expect(response.status).to eq(200)
      end

      it 'with deep query parameters' do
        get '/tables', params: { filter: { 'name' => 'Example Table' } }, headers: { authorization: 'k0kubun' }
        expect(response.status).to eq(200)
      end

      it 'with different deep query parameters' do
        get '/tables', params: { filter: { 'price' => 0 } }, headers: { authorization: 'k0kubun' }
        expect(response.status).to eq(200)
      end
    end

    it 'has a request spec which does not make any request' do
      expect(request).to eq(nil)
    end

    it 'does not return tables if unauthorized' do
      get '/tables'
      expect(response.status).to eq(401)
    end
  end

  describe '#show' do
    it 'returns a table' do
      get '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'does not return a table if unauthorized' do
      get '/tables/1'
      expect(response.status).to eq(401)
    end

    it 'does not return a table if not found' do
      get '/tables/2', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(404)
    end

    it 'does not return a table if not found (openapi: false)', openapi: false do
      get '/tables/3', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    it 'returns a table' do
      post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'k0kubun',
        description: 'description',
        database_id: 2,
      }.to_json
      expect(response.status).to eq(201)
    end

    it 'fails to create a table' do
      post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        description: 'description',
        database_id: 2,
      }.to_json
      expect(response.status).to eq(422)
    end

    it 'fails to create a table (2)' do
      post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'some_invalid_name',
        description: 'description',
        database_id: 2,
      }.to_json
      expect(response.status).to eq(422)
    end
  end

  describe '#update' do
    it 'returns a table' do
      patch '/tables/1', headers: { authorization: 'k0kubun' }, params: { name: 'test' }
      expect(response.status).to eq(200)
    end
  end

  describe '#destroy' do
    it 'returns a table' do
      delete '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'returns no content if specified' do
      delete '/tables/1', headers: { authorization: 'k0kubun' }, params: { no_content: true }
      expect(response.status).to eq(202)
    end
  end
end

RSpec.xdescribe 'Images', type: :request do
  describe '#payload' do
    it 'returns a image payload' do
      get '/images/1'
      expect(response.status).to eq(200)
    end
  end

  describe '#index' do
    it 'can return an object with an attribute of empty array' do
      get '/images'
      expect(response.status).to eq(200)
    end
  end

  describe '#upload' do
    before do
      png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
      QBoAAAAASUVORK5CYII='.unpack1('m')
      File.binwrite('test.png', png)
    end
    let(:image) { Rack::Test::UploadedFile.new('test.png', 'image/png') }

    it 'returns a image payload with upload' do
      post '/images/upload', params: { image: image }
      expect(response.status).to eq(200)
    end
  end

  describe '#upload_nested' do
    before do
      png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
      QBoAAAAASUVORK5CYII='.unpack1('m')
      File.binwrite('test.png', png)
    end
    let(:image) { Rack::Test::UploadedFile.new('test.png', 'image/png') }

    it 'returns a image payload with upload nested' do
      post '/images/upload_nested', params: { nested_image: { image: image, caption: 'Some caption' } }
      expect(response.status).to eq(200)
    end
  end

  describe '#upload_multiple' do
    before do
      png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
      QBoAAAAASUVORK5CYII='.unpack1('m')
      File.binwrite('test.png', png)
    end
    let(:image) { Rack::Test::UploadedFile.new('test.png', 'image/png') }

    it 'returns a image payload with upload multiple' do
      post '/images/upload_multiple', params: { images: [image, image] }
      expect(response.status).to eq(200)
    end
  end

  describe '#upload_multiple_nested' do
    before do
      png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
      QBoAAAAASUVORK5CYII='.unpack1('m')
      File.binwrite('test.png', png)
    end
    let(:image) { Rack::Test::UploadedFile.new('test.png', 'image/png') }

    it 'returns a image payload with upload multiple nested' do
      post '/images/upload_multiple_nested', params: { images: [{ image: image }, { image: image }] }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.xdescribe 'SecretKey securityScheme',
               type: :request,
               openapi: { security: [{ 'SecretApiKeyAuth' => [] }] } do
  describe '#secret_items' do
    it 'authorizes with secret key' do
      get '/secret_items',
          headers: {
            'Secret-Key' => '42',
          }
      expect(response.status).to eq(200)
    end
  end
end

RSpec.xdescribe 'Extra routes', type: :request do
  describe '#test_block' do
    it 'returns the block content' do
      get '/test_block'
      expect(response.status).to eq(200)
    end
  end
end

RSpec.xdescribe 'Engine test', type: :request do
  describe 'engine routes' do
    it 'returns some content from the engine' do
      get '/my_engine/eng_route'
      expect(response.status).to eq(200)
    end
  end
end

RSpec.xdescribe 'Engine extra routes', type: :request do
  describe '#test' do
    it 'returns the block content' do
      get '/my_engine/test'
      expect(response.status).to eq(200)
    end
  end
end
