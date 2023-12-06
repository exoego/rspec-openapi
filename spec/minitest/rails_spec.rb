# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'rails integration minitest' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/rails/doc/openapi.yaml', repo_root)
    end

    it 'generates the same spec/rails/doc/openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      minitest 'spec/integration_tests/rails_test.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/rails/doc/openapi.json', repo_root)
    end

    it 'generates the same spec/rails/doc/openapi.json' do
      org_yaml = JSON.parse(File.read(openapi_path))
      minitest 'spec/integration_tests/rails_test.rb', openapi: true, output: :json
      new_yaml = JSON.parse(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'with disabled OpenAPI generation' do
    it 'can run tests' do
      minitest 'spec/integration_tests/rails_test.rb'
    end
  end
end
