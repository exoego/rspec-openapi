require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/rails/doc/openapi.yaml', repo_root)
  end

  it 'generates the same spec/rails/doc/openapi.yaml' do
    org_yaml = YAML.load(File.read(openapi_path))
    rspec 'spec/requests/rails_spec.rb', openapi: true
    new_yaml = YAML.load(File.read(openapi_path))
    expect(new_yaml).to eq org_yaml
  end
end
