require 'spec_helper'
require 'fileutils'
require 'yaml'

RSpec.describe 'rack-test spec' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/roda/doc/openapi.yaml', repo_root)
  end

  it 'generates the same spec/roda/doc/openapi.yaml' do
    org_yaml = YAML.load(File.read(openapi_path))
    rspec 'spec/requests/roda_spec.rb', openapi: true
    new_yaml = YAML.load(File.read(openapi_path))
    expect(new_yaml).to eq org_yaml
  end
end
