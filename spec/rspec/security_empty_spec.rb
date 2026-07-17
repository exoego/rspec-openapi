# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

# Regression for operations opting out of security with `security: []`. They
# have no scheme to conflict with, but the empty array is truthy, so the
# after(:suite) cleanup used to call `dig(:security, 0).keys` on them and abort
# the whole run with NoMethodError before the document was written.
RSpec.describe 'security: [] opt-out' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/security_empty/openapi.yaml', repo_root)
  end

  it 'generates the committed security_empty/openapi.yaml' do
    org_yaml = YAML.safe_load(File.read(openapi_path))
    rspec 'spec/requests/rails_security_empty_spec.rb', openapi: true, output: :yaml
    new_yaml = YAML.safe_load(File.read(openapi_path))
    expect(new_yaml).to eq org_yaml
  end

  it 'keeps parameters on the public operation while cleaning the secured one' do
    rspec 'spec/requests/rails_security_empty_spec.rb', openapi: true, output: :yaml
    paths = YAML.safe_load(File.read(openapi_path)).fetch('paths')

    public_op = paths.dig('/widgets/{id}', 'get')
    expect(public_op['security']).to eq([])
    # The Secret-Key header is documented here: a public operation has no
    # security requirement for it to conflict with.
    expect(public_op['parameters'].map { |p| p['name'] }).to contain_exactly('id', 'Secret-Key')

    secured_op = paths.dig('/secret_items', 'get')
    expect(secured_op['security']).to eq([{ 'SecretApiKeyAuth' => [] }])
    # The Secret-Key header conflicts with the scheme and was the only
    # parameter, so the emptied parameters key is dropped.
    expect(secured_op).not_to have_key('parameters')

    other_scheme_op = paths.dig('/test_block', 'get')
    expect(other_scheme_op['security']).to eq([{ 'OtherApiKeyAuth' => [] }])
    # Only the header matching the operation's own scheme is removed; the
    # header of the unrelated scheme stays documented.
    expect(other_scheme_op['parameters'].map { |p| p['name'] }).to contain_exactly('Secret-Key')

    plain_op = paths.dig('/orgs/{org_id}/members/{user_id}', 'get')
    expect(plain_op).not_to have_key('security')
    expect(plain_op['parameters'].map { |p| p['name'] }).to include('Secret-Key')
  end
end
