# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, configuration errors' do
  include SpecHelper

  describe 'an invalid example_mode' do
    it 'aborts the example naming both the value and the example' do
      out, err, status = rspec_capture 'spec/requests/rails_invalid_example_mode_spec.rb', openapi: true, output: :yaml
      expect(status.success?).to eq(false)
      message = 'example_mode must be a Symbol/String in [:none, :single, :multiple] or a Hash with ' \
                ':request/:response keys, got 42 (example: invalid example_mode '
      expect(out + err).to include("#{message}aborts on a bare value that is not a mode)")
      expect(out + err).to include("#{message}aborts on a per-side value that is not a mode)")
    end
  end

  describe 'a per-directory config file that raises' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/broken_config/openapi.yaml', repo_root)
    end

    it 'warns and still writes the document' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      out, = rspec 'spec/requests/rails_broken_config_spec.rb', openapi: true, output: :yaml
      expect(out).to include('WARNING: Unable to load')
      expect(YAML.safe_load(File.read(openapi_path))).to eq org_yaml
    end
  end
end
