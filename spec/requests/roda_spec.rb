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

RSpec.shared_context 'Roda app' do
  include Rack::Test::Methods
  let(:app) { RodaApp }
end

RSpec.configure do |config|
  config.include_context 'Roda app', type: :request
end

RSpec.describe 'Roda', type: :request do
  describe '/roda', openapi: { summary: 'Create roda resource' } do
    context 'when id is given' do
      it 'returns 200' do
        post '/roda', { id: 1 }.to_json, 'CONTENT_TYPE' => 'application/json'
        expect(last_response.status).to eq(200)
      end
    end
  end
end

# Tests for example_mode feature (using dedicated test endpoints)

# Test :none mode - should generate only schema, no examples
RSpec.describe 'example_mode :none', type: :request do
  describe 'GET /example_mode_none', openapi: { example_mode: :none } do
    it 'generates schema without example' do
      get '/example_mode_none'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test :single mode (default) - should generate single example
RSpec.describe 'example_mode :single', type: :request do
  describe 'GET /example_mode_single' do
    it 'generates schema with single example' do
      get '/example_mode_single'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test :multiple mode - should generate named examples
RSpec.describe 'example_mode :multiple', type: :request do
  describe 'GET /example_mode_multiple', openapi: { example_mode: :multiple } do
    it 'first example' do
      get '/example_mode_multiple'
      expect(last_response.status).to eq(200)
    end

    it 'second example' do
      get '/example_mode_multiple'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test inheritance - parent sets :multiple, children inherit
RSpec.describe 'example_mode inheritance', type: :request, openapi: { example_mode: :multiple } do
  describe 'GET /example_mode_inherit' do
    # This test inherits :multiple from parent RSpec.describe
    it 'inherits multiple from parent' do
      get '/example_mode_inherit'
      expect(last_response.status).to eq(200)
    end

    it 'also inherits multiple from parent' do
      get '/example_mode_inherit'
      expect(last_response.status).to eq(200)
    end
  end

  # Test override to :single within :multiple context
  describe 'GET /example_mode_override_single', openapi: { example_mode: :single } do
    it 'overrides to single' do
      get '/example_mode_override_single'
      expect(last_response.status).to eq(200)
    end
  end

  # Test override to :none within :multiple context
  describe 'GET /example_mode_override_none', openapi: { example_mode: :none } do
    it 'overrides to none' do
      get '/example_mode_override_none'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test mixed example modes on same endpoint (merger conversion test)
# First test with :single (example), second test with :multiple (examples)
# Merger should convert :single to examples when mixed
RSpec.describe 'example_mode mixed', type: :request do
  describe 'GET /example_mode_mixed' do
    # First test with :single (default) - will be converted to examples by merger
    it 'first with single mode' do
      get '/example_mode_mixed'
      expect(last_response.status).to eq(200)
    end

    # Second test with :multiple - merger should convert the first to examples
    context 'with multiple', openapi: { example_mode: :multiple } do
      it 'second with multiple mode' do
        get '/example_mode_mixed'
        expect(last_response.status).to eq(200)
      end
    end
  end
end

# Test global enable_example = false overrides example_mode
RSpec.describe 'example_mode disabled globally', type: :request do
  before(:context) do
    @original_enable_example = RSpec::OpenAPI.enable_example
    RSpec::OpenAPI.enable_example = false
  end

  after(:context) do
    RSpec::OpenAPI.enable_example = @original_enable_example
  end

  describe 'GET /example_mode_disabled' do
    it 'does not generate examples for default mode' do
      get '/example_mode_disabled'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /example_mode_disabled_single', openapi: { example_mode: :single } do
    it 'does not generate examples for single mode' do
      get '/example_mode_disabled_single'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /example_mode_disabled_multiple', openapi: { example_mode: :multiple } do
    it 'does not generate examples for multiple mode' do
      get '/example_mode_disabled_multiple'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'GET /example_mode_disabled_none', openapi: { example_mode: :none } do
    it 'does not generate examples for none mode' do
      get '/example_mode_disabled_none'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test request body with array of primitive values (for adjust_params coverage)
RSpec.describe 'Tags with array params', type: :request do
  describe '#create' do
    it 'creates tags with array of strings' do
      post '/tags', { names: %w[ruby rails rspec], priority: 1 }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(201)
    end
  end
end

# Test custom example_key override
RSpec.describe 'Custom example_key', type: :request do
  describe 'GET /custom_example_key', openapi: { example_mode: :multiple, example_key: 'my_custom_key' } do
    it 'uses custom example key instead of description' do
      get '/custom_example_key'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test custom example_name override
RSpec.describe 'Custom example_name', type: :request do
  describe 'GET /custom_example_name', openapi: { example_mode: :multiple, example_name: 'My Custom Name' } do
    it 'uses custom example name for summary' do
      get '/custom_example_name'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test enable_example_summary = false
RSpec.describe 'Example summary disabled', type: :request do
  before(:context) do
    @original_enable_example_summary = RSpec::OpenAPI.enable_example_summary
    RSpec::OpenAPI.enable_example_summary = false
  end

  after(:context) do
    RSpec::OpenAPI.enable_example_summary = @original_enable_example_summary
  end

  describe 'GET /example_summary_disabled', openapi: { example_mode: :multiple } do
    it 'generates examples without summary' do
      get '/example_summary_disabled'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test empty example_name (triggers nil summary path)
RSpec.describe 'Empty example_name', type: :request do
  describe 'GET /empty_example_name', openapi: { example_mode: :multiple, example_name: '' } do
    it 'handles empty example_name' do
      get '/empty_example_name'
      expect(last_response.status).to eq(200)
    end
  end
end

# Test nested arrays response (key_transformer coverage)
RSpec.describe 'Nested arrays', type: :request do
  describe 'GET /nested_arrays_test' do
    it 'returns nested arrays' do
      get '/nested_arrays_test'
      expect(last_response.status).to eq(200)
    end
  end
end
