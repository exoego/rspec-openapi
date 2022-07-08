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

  describe "smart merge" do
    let(:openapi_path) do
      File.expand_path('spec/rails/doc/smart/openapi.yaml', repo_root)
    end

    let(:fallback_path) do
      File.expand_path('spec/rails/doc/smart/openapi.fail.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/rails/doc/smart/expected.yaml', repo_root)
    end

    it 'updates the spec/rails/doc/smart/openapi.yaml as same as in expected.yaml' do
      original_source = File.read(openapi_path)
      begin
        rspec 'spec/requests/rails_smart_merge_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.load(File.read(openapi_path))
        expected_yaml = YAML.load(File.read(expected_path))
        File.write(fallback_path, YAML.dump(new_yaml))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(openapi_path, original_source)
      end
    end
  end
end
