# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails request spec, a document that does not load' do
  include SpecHelper

  let(:openapi_path) do
    File.expand_path('spec/apps/rails/doc/dangling_alias/openapi.yaml', repo_root)
  end

  it 'aborts with the YAML error and leaves the document as it was' do
    original_source = File.read(openapi_path)
    out, err, status = rspec_capture 'spec/requests/rails_dangling_alias_spec.rb', openapi: true, output: :yaml
    expect(status.success?).to eq(false)
    # Psych 4 and later say the former. Psych 3 (Ruby 2.7 and 3.0) names the alias.
    expect(out + err).to match(/Alias parsing was not enabled|Unknown alias: missing/)
    expect(File.read(openapi_path)).to eq original_source
  ensure
    File.write(openapi_path, original_source) if original_source
  end
end
