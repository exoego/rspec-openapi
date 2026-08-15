# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'request_pattern selector' do
  include SpecHelper

  it 'applies request_pattern over the Rack::Test (roda) path too' do
    roda_path = File.expand_path('spec/apps/roda/doc/request_pattern.yaml', repo_root)
    rspec 'spec/requests/roda_request_pattern_spec.rb', openapi: true, output: :yaml
    operation = YAML.safe_load(File.read(roda_path)).dig('paths', '/widgets/1')

    expect(operation.keys).to eq(['delete'])
    expect(operation.dig('delete', 'summary')).to eq('Delete a widget')
    expect(operation.dig('delete', 'responses').keys).to eq(['200'])
  end

  it 'fails fast with a clear message for an unparseable or unmatched request_pattern' do
    out, err, status = rspec_capture 'spec/requests/rails_request_pattern_error_spec.rb', openapi: true, output: :yaml
    combined = out + err

    expect(status.success?).to eq(false)
    expect(combined).to match(/Invalid request_pattern "not-a-valid-pattern"/)
    expect(combined).to match(%r{request_pattern "GET /never/called" did not match})
    expect(combined).to match(/Recorded requests: \(no requests were recorded\)/)
  end
end
