# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'multi-request same path regression' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/multi_request_same_path/openapi.yaml', repo_root)
  end

  it 'keeps GET metadata when DELETE example performs a follow-up GET' do
    rspec 'spec/requests/rails_multi_request_same_path_spec.rb', openapi: true, output: :yaml
    spec = YAML.safe_load(File.read(openapi_path))

    operation = spec.dig('paths', '/multi_request_same_path')
    expect(operation).not_to be_nil

    get_op = operation['get']
    delete_op = operation['delete']

    expect(get_op['summary']).to eq('Get multi request resource')
    expect(get_op.dig('responses', '404', 'description')).to eq('returns 404 when missing=true')

    expect(delete_op['summary']).to eq('Delete multi request resource')
    expect(delete_op.dig('responses', '200', 'description')).to eq('deletes resource and verifies it is gone with a follow-up GET')
  end
end
