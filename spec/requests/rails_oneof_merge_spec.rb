# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Records conflicting types over a document that seed.yaml wrote by hand.
# Every route picks its body by the X-Variant header, so the recorded
# operation shows nothing but the bodies.
RSpec::OpenAPI.title = 'oneOf merge'
RSpec::OpenAPI.openapi_version = '3.1.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/oneof_merge/openapi.yaml', __dir__)

RSpec.describe 'oneOf merging across examples', type: :request do
  def record(path, variant)
    get path, headers: { 'X-Variant' => variant }
    expect(response).to have_http_status(:ok)
  end

  describe 'a hand-written oneOf left empty' do
    it('records a string') { record '/oneof_merge/empty_one_of', 'string' }
    it('records an integer') { record '/oneof_merge/empty_one_of', 'integer' }
  end

  describe 'objects that share no key, then a boolean' do
    it('records the first object') { record '/oneof_merge/objects_then_boolean', 'object_a' }
    it('records the second object') { record '/oneof_merge/objects_then_boolean', 'object_b' }
    it('records the boolean') { record '/oneof_merge/objects_then_boolean', 'boolean' }
  end

  describe 'a boolean, then objects that share no key' do
    it('records the boolean') { record '/oneof_merge/boolean_then_objects', 'boolean' }
    it('records the first object') { record '/oneof_merge/boolean_then_objects', 'object_a' }
    it('records the second object') { record '/oneof_merge/boolean_then_objects', 'object_b' }
  end

  describe 'an empty array, a typed array, then a string' do
    it('records the empty array') { record '/oneof_merge/arrays_then_string', 'empty' }
    it('records the typed array') { record '/oneof_merge/arrays_then_string', 'integers' }
    it('records the string') { record '/oneof_merge/arrays_then_string', 'string' }
  end
end
