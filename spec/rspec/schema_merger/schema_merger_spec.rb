require 'spec_helper'
require 'json'
require "rspec/openapi/schema_merger"

RSpec.describe "SchemaMerger" do
  include SpecHelper

  let(:base_path) do
    File.expand_path('spec/rspec/schema_merger/base.json', repo_root)
  end

  let(:input_path) do
    File.expand_path('spec/rspec/schema_merger/input.json', repo_root)
  end

  let(:expected_path) do
    File.expand_path('spec/rspec/schema_merger/expected.json', repo_root)
  end

  it "overwrite the supported key, but leaves the unsupported keys" do
    base_json = JSON.load(File.read(base_path))
    input_json = JSON.load(File.read(input_path))
    res = RSpec::OpenAPI::SchemaMerger.merge!(base_json, input_json)
    expected_json = JSON.load(File.read(expected_path))
    expect(res).to eq(expected_json)
  end
end
