require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'rack-test minitest' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/roda/doc/openapi.yaml', repo_root)
    end

    it 'generates the same spec/roda/doc/openapi.yaml' do
      org_yaml = YAML.load(File.read(openapi_path))
      minitest 'spec/integration_tests/roda_test.rb', openapi: true
      new_yaml = YAML.load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json output' do
    let(:openapi_path) do
      File.expand_path('spec/roda/doc/openapi.json', repo_root)
    end

    it 'generates the same spec/roda/doc/openapi.json' do
      org_yaml = YAML.load(File.read(openapi_path))
      minitest 'spec/integration_tests/roda_test.rb', openapi: true, output: :json
      new_yaml = YAML.load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end
end
