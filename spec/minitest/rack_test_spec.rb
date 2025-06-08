# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'rack-test minitest' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/roda/doc/minitest_openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/roda/doc/minitest_openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      minitest 'spec/integration_tests/roda_test.rb', openapi: true
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/roda/doc/minitest_openapi.json', repo_root)
    end

    it 'generates the same spec/apps/roda/doc/minitest_openapi.json' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      minitest 'spec/integration_tests/roda_test.rb', openapi: true, output: :json
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'with disabled OpenAPI generation' do
    it 'can run tests' do
      minitest 'spec/integration_tests/roda_test.rb'
    end
  end
end
