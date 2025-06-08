# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'rails request spec' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/rspec_openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.json', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/rspec_openapi.json' do
      org_json = JSON.parse(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :json
      new_json = JSON.parse(File.read(openapi_path))
      expect(new_json).to eq org_json
    end
  end

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
end
