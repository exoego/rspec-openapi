require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'rails request spec' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/rails/doc/openapi.yaml', repo_root)
    end

    it 'generates the same spec/rails/doc/openapi.yaml' do
      org_yaml = YAML.load(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/rails/doc/openapi.json', repo_root)
    end

    it 'generates the same spec/rails/doc/openapi.json' do
      org_yaml = JSON.load(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :json
      new_yaml = JSON.load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end
end
