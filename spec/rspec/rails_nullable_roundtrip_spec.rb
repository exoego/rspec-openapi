# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, multi-type nullable schema round-trip' do
  include SpecHelper

  describe 'hand-edited 3.2 document with a multi-type nullable schema' do
    let(:input_path) do
      File.expand_path('spec/apps/rails/doc/nullable_roundtrip/input.yaml', repo_root)
    end

    # The seed document carries a hand-written 409 response with a multi-type
    # nullable schema. Reading normalizes `type: [string, integer, "null"]` to
    # the internal `nullable` form and writing converts it back, so the
    # regenerated document shows whether the type array stays flat; the nested
    # [[string, integer], "null"] form is the bug this guards against (#451).
    # We restore the seed afterwards.
    it 'rewrites the hand-written multi-type nullable schema flat' do
      original_source = File.read(input_path)
      begin
        rspec 'spec/requests/rails_nullable_roundtrip_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(input_path))

        types = new_yaml.dig('paths', '/nullable_roundtrip', 'get', 'responses', '409',
                             'content', 'application/json', 'schema', 'type',)
        expect(types).to eq(['string', 'integer', 'null'])

        recorded = new_yaml.dig('paths', '/nullable_roundtrip', 'get', 'responses', '200',
                                'content', 'application/json', 'schema',)
        expect(recorded.dig('properties', 'ok', 'type')).to eq('boolean')
      ensure
        File.write(input_path, original_source)
      end
    end
  end
end
