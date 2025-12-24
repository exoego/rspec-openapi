# frozen_string_literal: true

require_relative '../apps/roda/roda_app'
require 'json'
require 'rack/test'

ENV['OPENAPI_OUTPUT'] ||= 'yaml'

RSpec::OpenAPI.title = 'OpenAPI Documentation'
RSpec::OpenAPI.path = File.expand_path("../apps/roda/doc/rspec_openapi.#{ENV.fetch('OPENAPI_OUTPUT', nil)}", __dir__)
RSpec::OpenAPI.ignored_paths = ['/admin/masters/extensions']

RSpec::OpenAPI.description_builder = lambda do |example|
  contexts = example.example_group.parent_groups.map(&:description).grep(/\Awhen /)
  [*contexts, 'it', example.description].join(' ')
end

RSpec.describe 'Roda', type: :request do
  include Rack::Test::Methods

  let(:app) do
    RodaApp
  end

  describe '/roda', openapi: { summary: 'Create roda resource' } do
    context 'when id is given' do
      it 'returns 200' do
        post '/roda', { id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(200)
      end
    end
  end

  # Test example_mode :multiple in Roda
  describe '/example_mode_roda', openapi: { example_mode: :multiple } do
    it 'first roda example' do
      get '/example_mode_roda'
      expect(last_response.status).to eq(200)
    end

    it 'second roda example' do
      get '/example_mode_roda'
      expect(last_response.status).to eq(200)
    end
  end

  # Test array primitives in request body for Roda
  describe '/tags_roda' do
    it 'creates tags with array of strings' do
      post '/tags_roda', { names: %w[roda ruby rack], priority: 2 }.to_json,
           'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq(200)
    end
  end
end
