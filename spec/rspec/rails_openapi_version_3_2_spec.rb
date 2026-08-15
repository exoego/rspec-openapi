# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'

RSpec.describe 'rails request spec, OpenAPI 3.2' do
  include SpecHelper

  describe 'OpenAPI 3.2 output' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2.yaml', repo_root)
    end

    let(:json_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2.json', repo_root)
    end

    # Matches the 3.1 fixture except for the version and `/stream` (itemSchema
    # here vs a string schema on 3.0/3.1). Committed to track 3.2 output too.
    it 'generates the 3.2 fixture (yaml and json)' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      org_json = JSON.parse(File.read(json_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :both, openapi_version: '3.2.0'
      new_yaml = YAML.safe_load(File.read(yaml_path))
      new_json = JSON.parse(File.read(json_path))
      expect(new_yaml).to eq org_yaml
      expect(new_json).to eq org_json
      expect(new_yaml).to eq new_json
    end

    it 'emits 3.2.0' do
      expect(YAML.safe_load(File.read(yaml_path))['openapi']).to eq('3.2.0')
    end
  end
end
