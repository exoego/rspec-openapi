# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.path = File.expand_path(
  "../apps/rails/doc/read_only/openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__,
)
RSpec::OpenAPI.read_only_builder = RSpec::OpenAPI::DEFAULT_READ_ONLY_BUILDER

# openapi.yaml shares Article and Comment between a request and a response
# through $refs written by hand. The PUT sends an article's id, so Article.id
# is not readOnly. Nothing sends a comment's id.
RSpec.describe 'Articles', type: :request do
  describe 'GET /read_only/articles/{id}' do
    it 'returns an article' do
      get '/read_only/articles/1'
      expect(response.status).to eq(200)
    end

    it 'returns an article with a string id' do
      get '/read_only/articles/a1', headers: { 'X-Variant': 'string' }
      expect(response.status).to eq(200)
    end
  end

  describe 'GET /read_only/articles' do
    # The two items differ on every listed property, so readOnly has to survive
    # the merge of a null with a string, of two types, of two arrays, of two
    # objects, and of a property only one item has.
    it 'lists articles', openapi: { read_only: ['id', 'uuid', 'updated_at', 'sections', 'stats'] } do
      get '/read_only/articles'
      expect(response.status).to eq(200)
    end
  end

  # The create sends a uuid the client made. Its request schema is inline, so
  # it carries no readOnly, and it reaches no component, so Article.uuid keeps
  # the readOnly the GET gives it.
  describe 'POST /read_only/articles' do
    it 'creates an article' do
      post '/read_only/articles', headers: { 'Content-Type': 'application/json' },
                                  params: { uuid: '0b9d', title: 'Hello', author_id: 7 }.to_json
      expect(response.status).to eq(201)
    end
  end

  # `read_only: false` stops this example from marking anything. Its request
  # still sends the id, which counts against the shared Article all the same.
  describe 'PUT /read_only/articles/{id}', openapi: { read_only: false } do
    it 'updates an article, sending its id and the ids of its sections' do
      put '/read_only/articles/1', headers: { 'Content-Type': 'application/json' }, params: {
        id: 1, title: 'Hello', sections_attributes: [{ id: 5, body: 'Intro' }],
      }.to_json
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'Comments', type: :request do
  describe 'GET /read_only/comments/{id}' do
    it 'returns a comment' do
      get '/read_only/comments/3'
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /read_only/comments' do
    it 'creates a comment' do
      post '/read_only/comments', headers: { 'Content-Type': 'application/json' }, params: { body: 'nice' }.to_json
      expect(response.status).to eq(201)
    end
  end
end

RSpec.describe 'Overrides', type: :request do
  # openapi.yaml shares Tagged between the GET response and the PUT. The list
  # marks title and author_id. The PUT also sends the id, a builder candidate
  # the list does not name, and that counts as a write all the same.
  describe '/read_only/tagged/{id}', openapi: { read_only: ['title', /_id\z/] } do
    describe 'GET' do
      it 'marks the listed properties instead of the default ones' do
        get '/read_only/tagged/1'
        expect(response.status).to eq(200)
      end
    end

    describe 'PUT' do
      it 'sends the id, which the list leaves to the builder' do
        put '/read_only/tagged/1', headers: { 'Content-Type': 'application/json' },
                                   params: { id: 1, title: 'Hello' }.to_json
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'GET /read_only/plain/{id}', openapi: { read_only: false } do
    it 'marks nothing' do
      get '/read_only/plain/1'
      expect(response.status).to eq(200)
    end

    describe 'GET /read_only/restored/{id}', openapi: { read_only: true } do
      it 'marks the default properties again' do
        get '/read_only/restored/1'
        expect(response.status).to eq(200)
      end
    end
  end
end
