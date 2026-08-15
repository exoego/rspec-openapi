# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, description preservation' do
  include SpecHelper

  describe 'description preservation with example_mode :none' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/description_preserve/openapi.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/description_preserve/expected.yaml', repo_root)
    end

    it 'preserves existing descriptions when example_mode is :none but overwrites with normal mode' do
      original_source = File.read(openapi_path)
      begin
        rspec 'spec/requests/rails_description_preserve_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(openapi_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(openapi_path, original_source)
      end
    end
  end
end
