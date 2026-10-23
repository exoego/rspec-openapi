# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

# Regression for response bodies whose fields are named like OpenAPI keywords.
# The after(:suite) cleanup used to walk into examples: a `security` field
# beside a `parameters` field aborted the run with NoMethodError, and an empty
# `required` beside `properties` was deleted from the example.
RSpec.describe 'fields named like OpenAPI keywords' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/keyword_fields/openapi.yaml', repo_root)
  end

  it 'generates the committed keyword_fields/openapi.yaml' do
    org_yaml = YAML.safe_load(File.read(openapi_path))
    rspec 'spec/requests/rails_keyword_fields_spec.rb', openapi: true, output: :yaml
    new_yaml = YAML.safe_load(File.read(openapi_path))
    expect(new_yaml).to eq org_yaml
  end

  it 'cleans the operation and the schema but not the examples' do
    rspec 'spec/requests/rails_keyword_fields_spec.rb', openapi: true, output: :yaml
    paths = YAML.safe_load(File.read(openapi_path)).fetch('paths')

    secured = paths.dig('/keyword_fields/security', 'get')
    # The Secret-Key header conflicts with the operation's scheme and was its
    # only parameter, so the emptied parameters key is dropped.
    expect(secured).not_to have_key('parameters')
    json = secured.dig('responses', '200', 'content', 'application/json')
    expect(json['example']).to eq('security' => 'guest', 'parameters' => [])

    json = paths.dig('/keyword_fields/required', 'get', 'responses', '200', 'content', 'application/json')
    # The empty object's schema loses its empty `required`.
    expect(json.dig('schema', 'properties', 'meta')).to eq('type' => 'object', 'properties' => {})
    values = json['examples'].values.map { |example| example['value'] }
    expect(values).to eq([{ 'properties' => { 'a' => 1 }, 'required' => [], 'meta' => {} }])
  end

  # The security cleanup is the first pass over `paths` after reading, so it
  # meets whatever a hand-edited document holds there. Both entries are
  # un-recorded and dropped from the output, like any other.
  it 'skips a non-object path item and a path item field' do
    original_source = File.read(openapi_path)
    begin
      seeded = YAML.safe_load(original_source)
      seeded['paths']['/weird_non_hash'] = 'just a string, not a path item object'
      seeded['paths']['/keyword_fields/security']['summary'] = 'hand written'
      File.write(openapi_path, YAML.dump(seeded))

      rspec 'spec/requests/rails_keyword_fields_spec.rb', openapi: true, output: :yaml
      expect(YAML.safe_load(File.read(openapi_path))).to eq YAML.safe_load(original_source)
    ensure
      File.write(openapi_path, original_source)
    end
  end
end
