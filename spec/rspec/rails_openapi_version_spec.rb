# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'pry'

RSpec.describe 'rails request spec, per OpenAPI version' do
  include SpecHelper

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
end
