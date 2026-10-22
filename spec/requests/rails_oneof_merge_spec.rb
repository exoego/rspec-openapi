# frozen_string_literal: true

ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../apps/rails/config/environment', __dir__)
require 'rspec/rails'

# Records conflicting types over a document that seed.yaml wrote by hand.
# Every route picks its body by the X-Variant header, so the recorded
# operation shows nothing but the bodies. What each case is for is spelled out
# in spec/rspec/oneof_merge_spec.rb.
RSpec::OpenAPI.title = 'oneOf merge'
RSpec::OpenAPI.openapi_version = '3.1.0'
RSpec::OpenAPI.path = File.expand_path('../apps/rails/doc/oneof_merge/openapi.yaml', __dir__)

RSpec.describe 'oneOf merging across examples', type: :request do
  def record(path, variant, query: nil)
    get [path, query].compact.join('?'), headers: { 'X-Variant' => variant }
    expect(response).to have_http_status(:ok)
  end

  # Route name => the bodies to record, in this order.
  {
    'empty_one_of' => ['string', 'integer'],
    'annotated' => ['integer'],
    'typeless' => ['mixed'],
    'typeless_enum' => ['mixed'],
    'typed_one_of' => ['ok'],
    'null_variants' => ['nulls', 'filled'],
    'flag_boolean' => ['boolean'],
    'flag_object' => ['object'],
    'pref_object' => ['object'],
    'pref_boolean' => ['boolean'],
    'tagged' => ['object'],
    'pruned' => ['array', 'object'],
    'schema_field' => ['string', 'integer'],
    'integer_then_number' => ['integer', 'float'],
    'number_then_integer' => ['float', 'integer'],
    'numbers_then_string' => ['integer', 'float', 'string'],
    'mixed_numbers' => ['mixed'],
    'tags_mixed_then_integers' => ['mixed', 'integers'],
    'tags_integers_then_mixed' => ['integers', 'mixed'],
    'objects_then_boolean' => ['object_a', 'object_b', 'boolean'],
    'boolean_then_objects' => ['boolean', 'object_a', 'object_b'],
    'arrays_then_string' => ['empty', 'integers', 'string'],
  }.each do |name, variants|
    variants.each do |variant|
      it("records #{variant} on #{name}") { record "/oneof_merge/#{name}", variant }
    end
  end

  it('records a string for a hand-written query parameter') { record '/oneof_merge/param', 'ok', query: 'q=foo' }

  describe 'a query parameter given empty, as a string and as an integer' do
    it('records it empty') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q' }
    it('records a string') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q=foo' }
    it('records an integer') { record '/oneof_merge/param_from_scratch', 'ok', query: 'q=1' }
  end
end
