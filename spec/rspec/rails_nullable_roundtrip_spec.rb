# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, multi-type nullable schema round-trip' do
  include SpecHelper

  describe 'hand-edited 3.2 document with a multi-type nullable schema' do
    # The seed document carries hand-written responses beside the recorded
    # 200. Reading normalizes `type: [string, integer, "null"]` to the internal
    # `nullable` form and writing converts it back, so the regenerated document
    # shows whether the type array stays flat; the nested
    # [[string, integer], "null"] form is the bug this guards against (#451).
    # We restore the seed afterwards.
    before(:context) do
      input_path = File.expand_path('spec/apps/rails/doc/nullable_roundtrip/input.yaml', repo_root)
      original_source = File.read(input_path)
      begin
        rspec 'spec/requests/rails_nullable_roundtrip_spec.rb', openapi: true, output: :yaml
        @recorded = YAML.safe_load(File.read(input_path))
      ensure
        File.write(input_path, original_source)
      end
    end

    def operation
      @recorded.dig('paths', '/nullable_roundtrip', 'get')
    end

    def response_schema(status)
      operation.dig('responses', status, 'content', 'application/json', 'schema')
    end

    it 'rewrites the hand-written multi-type nullable schema flat' do
      expect(response_schema('409')['type']).to eq(['string', 'integer', 'null'])
      expect(response_schema('200').dig('properties', 'ok', 'type')).to eq('boolean')
    end

    it 'lists null in the enum of a response, a header and a component named like a keyword, and of an allOf member' do
      nullable_enum = { 'type' => ['string', 'null'], 'enum' => ['a', nil] }

      expect(response_schema('default')).to eq(nullable_enum)
      expect(operation.dig('responses', '410', 'headers', 'x-mode', 'schema')).to eq(nullable_enum)
      expect(@recorded.dig('components', 'schemas', 'enum')).to eq(nullable_enum)
      expect(response_schema('412')).to eq('allOf' => [nullable_enum])
    end

    it 'leaves the enum of a oneOf variant alone, since a sibling is the one for null' do
      expect(response_schema('410')).to eq('oneOf' => [
        { 'type' => ['string', 'null'], 'enum' => ['a'] },
        { 'type' => 'null', 'description' => 'Cleared' },
      ])
    end

    it 'leaves an extension as written' do
      expect(operation['x-options']).to eq('nullable' => true, 'enum' => ['a'])
    end
  end
end
