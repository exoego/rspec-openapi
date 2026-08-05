# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'rails request spec, hand-edited document shapes' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/hand_edited/openapi.yaml', repo_root)
  end

  it 'generates the committed hand_edited/openapi.yaml' do
    org_yaml = YAML.safe_load(File.read(openapi_path))
    rspec 'spec/requests/rails_hand_edited_spec.rb', openapi: true, output: :yaml
    expect(YAML.safe_load(File.read(openapi_path))).to eq org_yaml
  end

  it 'keeps the hand-written response codes the recording never touches' do
    responses = YAML.safe_load(File.read(openapi_path)).dig('paths', '/example_mode_single', 'get', 'responses')
    expect(responses.keys).to contain_exactly('200', '409', '503')
    expect(responses.dig('503', 'content', 'application/json')).to eq({})
    one_of = responses.dig('409', 'content', 'application/json', 'schema', 'oneOf')
    expect(one_of.first).to eq({ '$ref' => '#/components/schemas/HandEditedConflict' })
    # A list item left empty mid-edit. The scan for referenced components has to
    # step over it rather than ask a nil for its $ref.
    expect(one_of[1]).to be_nil
  end
end
