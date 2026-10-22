# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'oneOf merging across examples' do
  include SpecHelper

  let(:openapi_path) { File.expand_path('spec/apps/rails/doc/oneof_merge/openapi.yaml', repo_root) }
  let(:seed_path) { File.expand_path('spec/apps/rails/doc/oneof_merge/seed.yaml', repo_root) }
  let(:committed) { YAML.safe_load(File.read(openapi_path)) }

  def record_over(path)
    original = File.read(openapi_path)
    File.write(openapi_path, File.read(path))
    rspec 'spec/requests/rails_oneof_merge_spec.rb', openapi: true, output: :yaml
    YAML.safe_load(File.read(openapi_path))
  ensure
    File.write(openapi_path, original) if original
  end

  def response_schema(path, *keys)
    committed.dig('paths', path, 'get', 'responses', '200', 'content', 'application/json', 'schema', *keys)
  end

  it 'records over seed.yaml into the committed openapi.yaml' do
    expect(record_over(seed_path)).to eq committed
  end

  it 'leaves the committed openapi.yaml unchanged when recorded over again' do
    expect(record_over(openapi_path)).to eq committed
  end

  it 'merges into a hand-written oneOf left empty' do
    expect(response_schema('/oneof_merge/empty_one_of', 'properties', 'value'))
      .to eq('oneOf' => [{ 'type' => 'integer' }, { 'type' => 'string' }])
  end

  it 'keeps a hand-written description beside the oneOf' do
    expect(response_schema('/oneof_merge/annotated', 'properties', 'value')).to eq(
      'oneOf' => [{ 'type' => 'integer' }, { 'type' => 'string' }],
      'description' => 'The display name',
      'deprecated' => true,
    )
  end

  it 'keeps what a hand-written null schema says beside the oneOf instead of as a variant' do
    one_of = [{ 'type' => 'integer' }, { 'type' => 'null' }, { 'type' => 'string' }]

    expect(response_schema('/oneof_merge/typeless', 'properties', 'values', 'items'))
      .to eq('oneOf' => one_of, 'description' => 'Set once the user picks one')
    expect(response_schema('/oneof_merge/typeless_enum', 'properties', 'values', 'items'))
      .to eq('oneOf' => one_of, 'enum' => [1, 'x'])
  end

  it 'merges objects that share no key into one object variant, whichever example runs first' do
    flag = {
      'oneOf' => [
        { 'type' => 'boolean' },
        { 'type' => 'object', 'properties' => { 'a' => { 'type' => 'integer' }, 'b' => { 'type' => 'string' } } },
      ],
    }

    expect(response_schema('/oneof_merge/objects_then_boolean', 'properties', 'flag')).to eq(flag)
    expect(response_schema('/oneof_merge/boolean_then_objects', 'properties', 'flag')).to eq(flag)
  end

  it 'merges an empty array and a typed array into one array variant' do
    expect(response_schema('/oneof_merge/arrays_then_string', 'properties', 'tags')).to eq(
      'oneOf' => [{ 'type' => 'array', 'items' => { 'type' => 'integer' } }, { 'type' => 'string' }],
    )
  end
end
