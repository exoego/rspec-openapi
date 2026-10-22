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

  describe 'a hand-written description on a string' do
    it('records an integer') { record '/oneof_merge/annotated', 'integer' }
  end

  describe 'hand-written null items with a description' do
    it('records items of two types') { record '/oneof_merge/typeless', 'mixed' }
  end

  describe 'hand-written null items with an enum' do
    it('records items of two types') { record '/oneof_merge/typeless_enum', 'mixed' }
  end

  describe 'fields named schema and required in the body' do
    it('records the first body') { record '/oneof_merge/schema_field', 'string' }
    it('records the second body') { record '/oneof_merge/schema_field', 'integer' }
  end

  describe 'an integer, then a number' do
    it('records an integer') { record '/oneof_merge/integer_then_number', 'integer' }
    it('records a number') { record '/oneof_merge/integer_then_number', 'float' }
  end

  describe 'a number, then an integer' do
    it('records a number') { record '/oneof_merge/number_then_integer', 'float' }
    it('records an integer') { record '/oneof_merge/number_then_integer', 'integer' }
  end

  describe 'an integer, a number, then a string' do
    it('records an integer') { record '/oneof_merge/numbers_then_string', 'integer' }
    it('records a number') { record '/oneof_merge/numbers_then_string', 'float' }
    it('records a string') { record '/oneof_merge/numbers_then_string', 'string' }
  end

  describe 'an integer beside a number in one array' do
    it('records both') { record '/oneof_merge/mixed_numbers', 'mixed' }
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
