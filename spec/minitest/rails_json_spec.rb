# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'rails integration minitest, json output' do
  include SpecHelper

  describe 'json' do
    let(:openapi_path) do
      File.expand_path('spec/apps/rails/doc/minitest_openapi.json', repo_root)
    end

    it 'generates the same spec/apps/rails/doc/minitest_openapi.json' do
      org_json = JSON.parse(File.read(openapi_path))
      minitest 'spec/integration_tests/rails_test.rb', openapi: true, output: :json
      new_json = JSON.parse(File.read(openapi_path))
      expect(new_json).to eq org_json
    end
  end
end
