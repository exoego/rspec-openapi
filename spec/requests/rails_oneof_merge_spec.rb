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
  def record(path, variant, query: nil)
    get [path, query].compact.join('?'), headers: { 'X-Variant' => variant }
    expect(response).to have_http_status(:ok)
  end

  describe 'a hand-written 409 with a type beside its oneOf' do
    it('records the 200') { record '/oneof_merge/typed_one_of', 'ok' }
  end

  describe 'a component shared by two endpoints' do
    it('records a boolean through the first') { record '/oneof_merge/flag_boolean', 'boolean' }
    it('records an object through the second') { record '/oneof_merge/flag_object', 'object' }
    it('records an object through the first') { record '/oneof_merge/pref_object', 'object' }
    it('records a boolean through the second') { record '/oneof_merge/pref_boolean', 'boolean' }
  end

  describe 'a $ref inside one variant of a hand-written oneOf' do
    it('records only that variant') { record '/oneof_merge/tagged', 'object' }
  end

  describe 'a hand-written object that is also recorded as an array' do
    it('records an array') { record '/oneof_merge/pruned', 'array' }
    it('records an object without one of the hand-written properties') { record '/oneof_merge/pruned', 'object' }
  end

  describe 'hand-written null variants' do
    it('records nulls') { record '/oneof_merge/null_variants', 'nulls' }
    it('records values') { record '/oneof_merge/null_variants', 'filled' }
  end

  describe 'a hand-written query parameter that may be null' do
    it('records a string') { record '/oneof_merge/param', 'ok', query: 'q=foo' }
  end

  describe 'a query parameter given empty, as a string and as an integer' do
    it('records it empty') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q' }
    it('records a string') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q=foo' }
    it('records an integer') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q=1' }
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

  describe 'an array of two types, then an array of one of them' do
    it('records both types') { record '/oneof_merge/tags_mixed_then_integers', 'mixed' }
    it('records integers') { record '/oneof_merge/tags_mixed_then_integers', 'integers' }
  end

  describe 'an array of one type, then an array of two types' do
    it('records integers') { record '/oneof_merge/tags_integers_then_mixed', 'integers' }
    it('records both types') { record '/oneof_merge/tags_integers_then_mixed', 'mixed' }
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
