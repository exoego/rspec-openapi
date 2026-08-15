# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, merging into an existing document' do
  include SpecHelper

  describe 'hand-edited 3.2 document round-trip' do
    let(:input_path) do
      File.expand_path('spec/apps/rails/doc/roundtrip/input.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/roundtrip/expected.yaml', repo_root)
    end

    # The seed document carries JSON-Schema null type arrays on an untouched
    # path. They are normalized while reading (then dropped from the output, as
    # any un-recorded path is), so the regenerated file holds only the recorded
    # path. We restore the seed afterwards.
    it 'normalizes null type arrays read from an existing document' do
      original_source = File.read(input_path)
      begin
        rspec 'spec/requests/rails_3_2_roundtrip_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(input_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(input_path, original_source)
      end
    end
  end
end
