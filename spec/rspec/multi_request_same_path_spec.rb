# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

# Regression for #371. A single example can perform several requests on the same
# path (a setup or teardown request alongside the documented one). The
# `openapi: { request_pattern: 'METHOD /path/template' }` selector picks which exchange
# defines the operation, so the trailing request can't contaminate it.
RSpec.describe 'multi-request same path regression' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/multi_request_same_path/openapi.yaml', repo_root)
  end

  it 'generates the committed multi_request_same_path/openapi.yaml' do
    org_yaml = YAML.safe_load(File.read(openapi_path))
    rspec 'spec/requests/rails_multi_request_same_path_spec.rb', openapi: true, output: :yaml
    new_yaml = YAML.safe_load(File.read(openapi_path))
    expect(new_yaml).to eq org_yaml
  end

  it 'keeps DELETE metadata when the example performs a follow-up GET' do
    rspec 'spec/requests/rails_multi_request_same_path_spec.rb', openapi: true, output: :yaml
    operation = YAML.safe_load(File.read(openapi_path)).dig('paths', '/widgets/{id}')

    delete_op = operation['delete']
    expect(delete_op['summary']).to eq('Delete a widget')
    # The documented DELETE is recorded, not the trailing GET 404.
    expect(delete_op['responses'].keys).to eq(['200'])
    expect(delete_op.dig('responses', '200', 'description'))
      .to eq('deletes the widget and verifies it is gone')

    get_op = operation['get']
    expect(get_op['summary']).to eq('Get a widget')
    expect(get_op['responses'].keys).to contain_exactly('200', '404')
  end

  it 'matches multi-segment path templates with several {param} placeholders' do
    rspec 'spec/requests/rails_multi_request_same_path_spec.rb', openapi: true, output: :yaml
    operation = YAML.safe_load(File.read(openapi_path)).dig('paths', '/orgs/{org_id}/members/{user_id}')

    delete_op = operation['delete']
    expect(delete_op['summary']).to eq('Remove an org member')
    # Only the DELETE 200 is recorded; the follow-up GET 404 must not leak in.
    expect(delete_op['responses'].keys).to eq(['200'])
    expect(delete_op.dig('responses', '200', 'description'))
      .to eq('removes the member and verifies it is gone')

    # Each {param} segment is captured independently.
    param_names = delete_op['parameters'].map { |p| p['name'] }
    expect(param_names).to contain_exactly('org_id', 'user_id')

    get_op = operation['get']
    expect(get_op['summary']).to eq('Get an org member')
    expect(get_op['responses'].keys).to contain_exactly('200', '404')
  end

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
