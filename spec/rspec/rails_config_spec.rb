# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, configuration' do
  include SpecHelper

  describe 'settings that take a proc or a hook' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/config/openapi.yaml', repo_root)
    end

    it 'resolves title and path per example, runs the post process hook and terminates the comment' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_config_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end

    it 'writes the comment as its own line even though the configured one has no newline' do
      expect(File.read(openapi_path).lines.first)
        .to eq("# This file is auto-generated. Edits are preserved where possible.\n")
    end

    it 'leaves summaries out of examples when enable_example_summary is off' do
      operation = YAML.safe_load(File.read(openapi_path)).dig('paths', '/example_mode_multiple', 'get')
      examples = operation.dig('responses', '200', 'content', 'application/json', 'examples')
      expect(examples.values.map(&:keys)).to eq([['value']])
    end
  end

  describe 'an invalid example_mode' do
    it 'aborts the example naming both the value and the example' do
      out, err, status = rspec_capture 'spec/requests/rails_invalid_example_mode_spec.rb', openapi: true, output: :yaml
      expect(status.success?).to eq(false)
      expect(out + err).to include(
        'example_mode must be a Symbol/String in [:none, :single, :multiple] or a Hash with ' \
        ':request/:response keys, got 42 (example: invalid example_mode aborts the example)',
      )
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
