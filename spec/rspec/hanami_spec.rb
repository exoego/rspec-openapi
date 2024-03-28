# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'hanami request spec' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/hanami/doc/openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/hanami/doc/openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/hanami_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/apps/hanami/doc/openapi.json', repo_root)
    end

    it 'generates the same spec/apps/hanami/doc/openapi.json' do
      org_json = JSON.parse(File.read(openapi_path))
      rspec 'spec/requests/hanami_spec.rb', openapi: true, output: :json
      new_json = JSON.parse(File.read(openapi_path))
      expect(new_json).to eq org_json
    end
  end
end
