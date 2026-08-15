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

  describe 'DEBUG in the environment' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/config/openapi.yaml', repo_root)
    end

    # DEBUG is read once while rspec-openapi loads, so it has to be set for the
    # spawned run rather than from inside the spec.
    it 'records the same document as a run without it' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_config_spec.rb', openapi: true, output: :yaml, debug: true
      expect(YAML.safe_load(File.read(openapi_path))).to eq org_yaml
    end
  end
end
