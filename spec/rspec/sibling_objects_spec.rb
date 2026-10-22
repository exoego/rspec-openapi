# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'objects merged across sibling array items' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/sibling_objects/openapi.yaml', repo_root)
  end

  def response_schema(path)
    YAML.safe_load(File.read(openapi_path))
        .dig('paths', path, 'get', 'responses', '200', 'content', 'application/json', 'schema')
  end

  def meta_schema(path)
    response_schema(path).dig('properties', 'products', 'items', 'properties', 'meta')
  end

  it 'generates the committed sibling_objects/openapi.yaml from scratch' do
    committed = File.read(openapi_path)
    begin
      File.delete(openapi_path)
      rspec 'spec/requests/rails_sibling_objects_spec.rb', openapi: true, output: :yaml
      expect(YAML.safe_load(File.read(openapi_path))).to eq YAML.safe_load(committed)
    ensure
      File.write(openapi_path, committed)
    end
  end

  it 'leaves the committed sibling_objects/openapi.yaml unchanged when regenerated over it' do
    committed = YAML.safe_load(File.read(openapi_path))
    rspec 'spec/requests/rails_sibling_objects_spec.rb', openapi: true, output: :yaml
    expect(YAML.safe_load(File.read(openapi_path))).to eq committed
  end

  it 'gives every sibling the same dictionary schema, so its oneOf survives the merge' do
    expect(meta_schema('/sibling_objects/dictionary')).to eq(
      'type' => 'object',
      'additionalProperties' => { 'oneOf' => [{ 'type' => 'string' }, { 'type' => 'integer' }] },
    )
  end

  it 'records required only alongside properties' do
    expect(meta_schema('/sibling_objects/hybrid')).to eq(
      'type' => 'object',
      'properties' => {
        'id' => { 'type' => 'integer' },
        'a' => { 'type' => ['integer', 'null'] },
        'b' => { 'type' => ['string', 'null'] },
      },
      'required' => ['id'],
      'additionalProperties' => { 'type' => 'string' },
    )
  end

  it 'never records an empty additionalProperties schema' do
    expect(meta_schema('/sibling_objects/empty_override')).not_to have_key('additionalProperties')
  end

  it 'merges and converts properties named default and enum like any other property' do
    option = response_schema('/sibling_objects/settings').dig('properties', 'options', 'items', 'properties')
    one_of = { 'oneOf' => [{ 'type' => 'boolean' }, { 'type' => 'null' }, { 'type' => 'string' }] }

    expect(option).to eq('default' => one_of, 'enum' => one_of)
  end
end
