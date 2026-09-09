# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, partial update' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/partial_update/openapi.yaml', repo_root)
  end

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

  # The inner spec has its own directory so the run can name the directory as
  # well as the file. .rspec's exclude pattern is relative to the directory
  # given, so it does not hide the file there.
  it 'adds and updates without removing anything when spec files are named' do
    out, = rspec 'spec/requests/partial_update/rails_partial_update_spec.rb', openapi: true, partial: :auto
    expect(generated).to eq expected('expected_partial')
    expect(out).to include('nothing was removed from the document')
  end

  it 'adds and updates without removing anything when a filter narrows the run' do
    out, = rspec 'spec/requests/partial_update', '-e', 'returns ok', openapi: true, partial: :auto
    expect(generated).to eq expected('expected_partial')
    expect(out).to include('nothing was removed from the document')
  end

  it 'removes what the run did not record when a directory is given' do
    out, = rspec 'spec/requests/partial_update', openapi: true, partial: :auto
    expect(generated).to eq expected('expected_full')
    expect(out).not_to include('nothing was removed from the document')
  end
end
