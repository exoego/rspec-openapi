# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

# A run over part of the suite adds and updates the document without removing
# anything. The document starts with entries nothing records any more, and the
# two spec files of spec/requests/partial_update run in the ways a user narrows
# a run.
RSpec.describe 'rails request spec, partial update' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/partial_update/openapi.yaml', repo_root)
  end
  let(:spec_dir) { 'spec/requests/partial_update' }
  let(:recording_spec) { "#{spec_dir}/rails_partial_update_spec.rb" }
  let(:sibling_spec) { "#{spec_dir}/rails_partial_update_sibling_spec.rb" }
  let(:notice) { 'nothing was removed from the document' }

  around do |example|
    original_source = File.read(openapi_path)
    example.run
  ensure
    File.write(openapi_path, original_source)
  end

  def generated
    YAML.safe_load(File.read(openapi_path))
  end

  def expected(name)
    YAML.safe_load(File.read(File.expand_path("spec/apps/rails/doc/partial_update/#{name}.yaml", repo_root)))
  end

  it 'removes nothing when a spec file next to the recording one is left out' do
    out, = rspec recording_spec, openapi: true, partial: :auto
    expect(generated).to eq expected('expected_partial')
    expect(out).to include(notice)
  end

  it 'removes nothing when a filter narrows the run' do
    out, = rspec recording_spec, sibling_spec, '-e', 'returns ok', openapi: true, partial: :auto
    expect(generated).to eq expected('expected_partial')
    expect(out).to include(notice)
  end

  it 'removes stale entries when every spec file of the directory is named' do
    out, = rspec recording_spec, sibling_spec, openapi: true, partial: :auto
    expect(generated).to eq expected('expected_full')
    expect(out).not_to include(notice)
  end

  # .rspec excludes spec/requests, but relative to the directory named, so the
  # files there still run.
  it 'removes stale entries when the directory is named' do
    out, = rspec spec_dir, openapi: true, partial: :auto
    expect(generated).to eq expected('expected_full')
    expect(out).not_to include(notice)
  end

  # parallel_tests marks each worker with TEST_ENV_NUMBER, an empty string for
  # the first one. This worker got every file of the directory, which would
  # otherwise count as a full run.
  it 'removes nothing in a parallel_tests worker, whatever files it got' do
    out, = rspec recording_spec, sibling_spec, openapi: true, partial: :auto, env: { 'TEST_ENV_NUMBER' => '' }
    expect(generated).to eq expected('expected_partial')
    expect(out).to include(notice)
  end

  it 'removes stale entries when partial_update is false, whatever the run' do
    out, = rspec recording_spec, openapi: true, partial: false
    expect(generated['paths'].keys).to eq(['/roundtrip'])
    operation = generated.dig('paths', '/roundtrip', 'get')
    expect(operation['parameters'].map { |parameter| parameter['name'] }).to eq(['page'])
    expect(generated.dig('components', 'schemas', 'Ok', 'properties').keys).to eq(['ok'])
    expect(out).not_to include(notice)
  end

  it 'removes nothing when partial_update is true, whatever the run' do
    out, = rspec recording_spec, sibling_spec, openapi: true, partial: true
    expect(generated).to eq expected('expected_partial')
    expect(out).not_to include(notice)
  end
end
