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

  def response_content(path, status, *keys)
    committed.dig('paths', path, 'get', 'responses', status, 'content', 'application/json', *keys)
  end

  def response_schema(path, *keys)
    response_content(path, '200', 'schema', *keys)
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

  it 'merges the two shapes of a shared component into a oneOf, whichever endpoint comes first' do
    value = {
      'oneOf' => [
        { 'type' => 'boolean' },
        { 'type' => 'object', 'properties' => { 'x' => { 'type' => 'string' } }, 'required' => ['x'] },
      ],
    }

    expect(committed.dig('components', 'schemas', 'FlagSetting', 'properties', 'value')).to eq(value)
    expect(committed.dig('components', 'schemas', 'PrefSetting', 'properties', 'value')).to eq(value)
  end

  it 'keeps a component referenced from inside a oneOf variant when only that variant is recorded' do
    expect(response_schema('/oneof_merge/tagged', 'oneOf')).to eq([
      { 'type' => 'boolean' },
      {
        'type' => 'object',
        'properties' => { 'tag' => { '$ref' => '#/components/schemas/Tag' } },
        'required' => ['tag'],
      },
    ])
    expect(committed.dig('components', 'schemas', 'Tag')).to eq(
      'type' => 'object', 'properties' => { 'name' => { 'type' => 'string' } }, 'required' => ['name'],
    )
  end

  it 'drops a property the API stopped returning from the variant it sits in' do
    expect(response_schema('/oneof_merge/pruned', 'oneOf')).to eq([
      { 'type' => 'array', 'items' => { 'type' => 'integer' } },
      { 'type' => 'object', 'properties' => { 'a' => { 'type' => 'integer' } }, 'required' => ['a'] },
    ])
  end

  it 'leaves a variant alone, $ref and all, when this run recorded only the other one' do
    expect(response_schema('/oneof_merge/untagged', 'oneOf')).to eq(response_schema('/oneof_merge/tagged', 'oneOf'))
  end

  it 'adds no second null variant beside a hand-written one' do
    properties = response_schema('/oneof_merge/null_variants', 'properties')

    expect(properties['value']['oneOf']).to contain_exactly(
      { 'type' => 'null', 'description' => 'Cleared by the user' }, { 'type' => 'string' },
    )
    expect(properties['other']['oneOf']).to contain_exactly({ 'type' => ['string', 'null'] }, { 'type' => 'integer' })
  end

  it 'writes a hand-written type beside a oneOf back as it was' do
    expect(response_content('/oneof_merge/typed_one_of', '409', 'schema')).to eq(
      'type' => ['object', 'null'],
      'oneOf' => [{ 'required' => ['meow'] }, { 'required' => ['bark'] }],
    )
  end

  describe 'a query parameter that may be null' do
    let(:nullable_one_of) { { 'oneOf' => [{ 'type' => 'integer' }, { 'type' => 'null' }, { 'type' => 'string' }] } }

    it 'keeps the null variant written by hand' do
      expect(committed.dig('paths', '/oneof_merge/param', 'get', 'parameters')).to eq([
        { 'name' => 'q', 'in' => 'query', 'required' => false, 'schema' => nullable_one_of, 'example' => 'foo' },
      ])
    end

    it 'records the parameter given empty as the null variant' do
      expect(committed.dig('paths', '/oneof_merge/param_from_scratch', 'get', 'parameters', 0, 'schema'))
        .to eq(nullable_one_of)
    end
  end

  it 'keeps the last recorded example as it was, even where a field is named like a schema key' do
    expect(response_content('/oneof_merge/schema_field', '200', 'example'))
      .to eq('id' => 2, 'schema' => { 'type' => 'integer' }, 'required' => ['name'])
  end

  it 'records an integer that is also a number as a number, whichever example runs first' do
    number = { 'type' => 'number', 'format' => 'float' }

    expect(response_schema('/oneof_merge/integer_then_number', 'properties', 'value')).to eq(number)
    expect(response_schema('/oneof_merge/number_then_integer', 'properties', 'value')).to eq(number)
    expect(response_schema('/oneof_merge/numbers_then_string', 'properties', 'value'))
      .to eq('oneOf' => [number, { 'type' => 'string' }])
    expect(response_schema('/oneof_merge/mixed_numbers', 'properties', 'values', 'items')).to eq(number)
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

  it 'orders the variants by type, whichever example runs first' do
    items = { 'oneOf' => [{ 'type' => 'integer' }, { 'type' => 'string' }] }

    expect(response_schema('/oneof_merge/tags_mixed_then_integers', 'properties', 'tags', 'items')).to eq(items)
    expect(response_schema('/oneof_merge/tags_integers_then_mixed', 'properties', 'tags', 'items')).to eq(items)
  end

  it 'merges an empty array and a typed array into one array variant' do
    expect(response_schema('/oneof_merge/arrays_then_string', 'properties', 'tags')).to eq(
      'oneOf' => [{ 'type' => 'array', 'items' => { 'type' => 'integer' } }, { 'type' => 'string' }],
    )
  end
end
