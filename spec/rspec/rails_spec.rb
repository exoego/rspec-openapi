# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'

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

    # Builds the document from scratch, as deleting the file and rerunning does.
    # A run over an existing file keeps its key order, so only a fresh build
    # shows whether the examples were sorted. The inner specs define them out
    # of alphabetical order.
    it 'sorts the named examples of a request body and a response' do
      original_source = File.read(openapi_path)
      begin
        File.delete(openapi_path)
        rspec 'spec/requests/rails_spec.rb', openapi: true, output: :yaml
        paths = YAML.safe_load(File.read(openapi_path))['paths']

        operation = paths.dig('/example_mode_multiple_request_body', 'post')
        request_examples = operation.dig('requestBody', 'content', 'application/json', 'examples')
        expect(request_examples.keys).to eq(['with_email_password_signin', 'with_otp_signin', 'with_validation_error'])
        response_examples = operation.dig('responses', '200', 'content', 'application/json', 'examples')
        expect(response_examples.keys).to eq(['with_email_password_signin', 'with_otp_signin'])

        operation = paths.dig('/example_mode_inherit', 'get')
        inherited_examples = operation.dig('responses', '200', 'content', 'application/json', 'examples')
        expect(inherited_examples.keys).to eq(['also_inherits_multiple_from_parent', 'inherits_multiple_from_parent'])
      ensure
        File.write(openapi_path, original_source)
      end
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
end
