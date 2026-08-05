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

  describe 'both yaml and json in a single run' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.yaml', repo_root)
    end

    let(:json_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.json', repo_root)
    end

    it 'generates both files from one run with identical content' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      org_json = JSON.parse(File.read(json_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :both
      new_yaml = YAML.safe_load(File.read(yaml_path))
      new_json = JSON.parse(File.read(json_path))
      expect(new_yaml).to eq org_yaml
      expect(new_json).to eq org_json
      expect(new_yaml).to eq new_json
    end
  end
end
