# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, smart merge' do
  include SpecHelper

  describe 'smart merge' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/smart/openapi.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/smart/expected.yaml', repo_root)
    end

    it 'updates the spec/apps/rails/doc/smart/openapi.yaml as same as in expected.yaml' do
      original_source = File.read(openapi_path)
      begin
        rspec 'spec/requests/rails_smart_merge_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(openapi_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(openapi_path, original_source)
      end
    end
  end

  # The README steps for $ref, on an API that wraps every body in an envelope.
  # openapi.yaml is the document after the $refs were written by hand.
  describe 'smart merge of an API that wraps every body in an envelope' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/smart_envelope/openapi.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/smart_envelope/expected.yaml', repo_root)
    end

    it 'generates the schemas referenced from inside the envelopes' do
      original_source = File.read(openapi_path)
      begin
        rspec 'spec/requests/rails_smart_envelope_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(openapi_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(openapi_path, original_source)
      end
    end
  end
end
