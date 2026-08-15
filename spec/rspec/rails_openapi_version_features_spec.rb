# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, version-specific features' do
  include SpecHelper

  describe 'OpenAPI 3.2 HTTP methods (query / additionalOperations)' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2_methods.yaml', repo_root)
    end

    # The request spec is a no-op on Rails < 7.1 (fixture unchanged, so this
    # trivially holds); on 7.1+ it is regenerated and checked.
    it 'records the query field and additionalOperations map' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      rspec 'spec/requests/rails_3_2_methods_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(yaml_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'OpenAPI 3.2 streaming media types (itemSchema)' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2_streaming.yaml', repo_root)
    end

    it 'records json-seq and SSE streams as itemSchema' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      rspec 'spec/requests/rails_3_2_streaming_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(yaml_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'unsupported OpenAPI version' do
    it 'aborts the run with a validation message' do
      out, err, status = rspec_capture 'spec/requests/rails_invalid_version_spec.rb', openapi: true, output: :yaml
      expect(status.success?).to eq(false)
      # RSpec reports the load-time ArgumentError on stdout; warnings go to stderr.
      expect(out + err).to match(/Unsupported OpenAPI version/)
    end
  end
end
