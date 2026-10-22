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
end
