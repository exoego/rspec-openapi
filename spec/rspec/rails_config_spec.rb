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
  end

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
