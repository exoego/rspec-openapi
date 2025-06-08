# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'rack-test spec' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/roda/doc/rspec_openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/roda/doc/rspec_openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/roda_spec.rb', openapi: true
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/roda/doc/rspec_openapi.json', repo_root)
    end

    it 'generates the same spec/apps/roda/doc/rspec_openapi.json' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/roda_spec.rb', openapi: true, output: :json
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end
end
