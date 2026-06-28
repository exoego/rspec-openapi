# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'rails request spec' do
  include SpecHelper

  describe 'yaml output' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.yaml', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/rspec_openapi.yaml' do
      org_yaml = YAML.safe_load(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :yaml
      new_yaml = YAML.safe_load(File.read(openapi_path))
      expect(new_yaml).to eq org_yaml
    end
  end

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.json', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/rspec_openapi.json' do
      org_json = JSON.parse(File.read(openapi_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :json
      new_json = JSON.parse(File.read(openapi_path))
      expect(new_json).to eq org_json
    end
  end

  describe 'both yaml and json in a single run' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.yaml', repo_root)
    end

    let(:json_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi.json', repo_root)
    end

    it 'generates both files from one run with identical content' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      org_json = JSON.parse(File.read(json_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :both
      new_yaml = YAML.safe_load(File.read(yaml_path))
      new_json = JSON.parse(File.read(json_path))
      expect(new_yaml).to eq org_yaml
      expect(new_json).to eq org_json
      expect(new_yaml).to eq new_json
    end
  end

  describe 'OpenAPI 3.1 output' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.1.yaml', repo_root)
    end

    let(:json_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.1.json', repo_root)
    end

    # Collect every `type:` value in the tree, regardless of path.
    def collect_types(node, acc = [])
      case node
      when Hash
        acc << node['type'] if node.key?('type')
        node.each_value { |v| collect_types(v, acc) }
      when Array
        node.each { |v| collect_types(v, acc) }
      end
      acc
    end

    def deep_keys(node, acc = [])
      case node
      when Hash
        node.each do |k, v|
          acc << k
          deep_keys(v, acc)
        end
      when Array
        node.each { |v| deep_keys(v, acc) }
      end
      acc
    end

    it 'generates the JSON-Schema-based 3.1 fixture (yaml and json)' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      org_json = JSON.parse(File.read(json_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :both, openapi_version: '3.1.1'
      new_yaml = YAML.safe_load(File.read(yaml_path))
      new_json = JSON.parse(File.read(json_path))
      expect(new_yaml).to eq org_yaml
      expect(new_json).to eq org_json
      expect(new_yaml).to eq new_json
    end

    it 'emits 3.1.1, drops nullable and uses null type arrays' do
      schema = YAML.safe_load(File.read(yaml_path))
      expect(schema['openapi']).to eq('3.1.1')
      expect(deep_keys(schema)).not_to include('nullable')
      expect(collect_types(schema)).to include(['string', 'null'])
    end
  end

  describe 'OpenAPI 3.2 output' do
    let(:yaml_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2.yaml', repo_root)
    end

    let(:json_path) do
      File.expand_path('spec/apps/rails/doc/rspec_openapi_3.2.json', repo_root)
    end

    # Matches the 3.1 fixture except for the version and `/stream` (itemSchema
    # here vs a string schema on 3.0/3.1). Committed to track 3.2 output too.
    it 'generates the 3.2 fixture (yaml and json)' do
      org_yaml = YAML.safe_load(File.read(yaml_path))
      org_json = JSON.parse(File.read(json_path))
      rspec 'spec/requests/rails_spec.rb', openapi: true, output: :both, openapi_version: '3.2.0'
      new_yaml = YAML.safe_load(File.read(yaml_path))
      new_json = JSON.parse(File.read(json_path))
      expect(new_yaml).to eq org_yaml
      expect(new_json).to eq org_json
      expect(new_yaml).to eq new_json
    end

    it 'emits 3.2.0' do
      expect(YAML.safe_load(File.read(yaml_path))['openapi']).to eq('3.2.0')
    end
  end

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

  describe 'hand-edited 3.2 document round-trip' do
    let(:input_path) do
      File.expand_path('spec/apps/rails/doc/roundtrip/input.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/roundtrip/expected.yaml', repo_root)
    end

    # The seed document carries JSON-Schema null type arrays on an untouched
    # path. They are normalized while reading (then dropped from the output, as
    # any un-recorded path is), so the regenerated file holds only the recorded
    # path. We restore the seed afterwards.
    it 'normalizes null type arrays read from an existing document' do
      original_source = File.read(input_path)
      begin
        rspec 'spec/requests/rails_3_2_roundtrip_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(input_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(input_path, original_source)
      end
    end
  end

  describe 'smart merge' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/smart/openapi.yaml', repo_root)
    end

    let(:expected_path) do
      File.expand_path('spec/apps/rails/doc/smart/expected.yaml', repo_root)
    end

    it 'updates the spec/apps/rails/doc/smart/openapi.yaml as same as in expected.yaml' do
      original_source = File.read(openapi_path)
      begin
        rspec 'spec/requests/rails_smart_merge_spec.rb', openapi: true, output: :yaml
        new_yaml = YAML.safe_load(File.read(openapi_path))
        expected_yaml = YAML.safe_load(File.read(expected_path))
        expect(new_yaml).to eq expected_yaml
      ensure
        File.write(openapi_path, original_source)
      end
    end
  end

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
