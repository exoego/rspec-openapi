# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, readOnly' do
  include SpecHelper

  let(:request_spec) { 'spec/requests/rails_read_only_spec.rb' }
  let(:openapi_path) { File.expand_path('spec/apps/rails/doc/read_only/openapi.yaml', repo_root) }
  let(:expected_path) { File.expand_path('spec/apps/rails/doc/read_only/expected.yaml', repo_root) }

  def document
    YAML.safe_load(File.read(openapi_path))
  end

  around do |example|
    original_source = File.read(openapi_path)
    begin
      example.run
    ensure
      File.write(openapi_path, original_source)
    end
  end

  it 'marks server-assigned properties readOnly unless a request sends them' do
    rspec request_spec, openapi: true, output: :yaml
    expect(document).to eq YAML.safe_load(File.read(expected_path))
  end

  # parallel_tests workers are partial runs in no fixed order, so a run that
  # sees only the reads must not undo the write another run saw.
  [
    ['PUT /read_only/articles/{id}', 'GET /read_only/articles/{id}'],
    ['GET /read_only/articles/{id}', 'PUT /read_only/articles/{id}'],
  ].each do |order|
    it "keeps the request side's false across partial runs, #{order.first[0, 3]} first" do
      order.each { |filter| rspec request_spec, '-e', filter, openapi: true, output: :yaml, partial: true }
      article = document.dig('components', 'schemas', 'Article', 'properties')
      expect(article.dig('id', 'readOnly')).to eq(false)
      expect(article.dig('uuid', 'readOnly')).to eq(true)
    end
  end

  # A full run decides readOnly anew. Once no request sends the id any more,
  # the component stops holding it at false.
  it 'lifts a false in a full run once no request sends the property' do
    rspec request_spec, openapi: true, output: :yaml
    rspec request_spec, '-e', 'GET /read_only/articles/{id}', openapi: true, output: :yaml
    article = document.dig('components', 'schemas', 'Article', 'properties')
    expect(article.dig('id', 'readOnly')).to eq(true)
  end
end
