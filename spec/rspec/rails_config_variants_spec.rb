# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, configuration variants' do
  include SpecHelper

  describe 'enable_example turned off' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/no_example/openapi.yaml', repo_root)
    end

    it 'generates the committed no_example/openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_no_example_spec.rb', openapi: true, output: :yaml
      expect(YAML.safe_load(File.read(openapi_path))).to eq org_yaml
    end

    it 'leaves example values out of parameters and the request body' do
      expect(File.read(openapi_path)).not_to include('example:')
    end
  end

  describe 'controller specs as an example type' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/controller/openapi.yaml', repo_root)
    end

    it 'generates the committed controller/openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_controller_spec.rb', openapi: true, output: :yaml
      expect(YAML.safe_load(File.read(openapi_path))).to eq org_yaml
    end

    it 'does not record a controller example that issued no request' do
      rspec 'spec/requests/rails_controller_spec.rb', openapi: true, output: :yaml
      paths = YAML.safe_load(File.read(openapi_path)).fetch('paths').keys
      expect(paths).to all(start_with('/'))
    end
  end
end
