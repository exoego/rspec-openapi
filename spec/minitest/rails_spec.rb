# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails integration minitest' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/minitest_openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/minitest_openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      minitest 'spec/integration_tests/rails_test.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end
end
