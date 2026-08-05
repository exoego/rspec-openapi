# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'minitest integration, hook error handling' do
  include SpecHelper

  it 'reports the records it could not build' do
    out, err, = minitest 'spec/integration_tests/rails_hook_error_test.rb', openapi: true, output: :yaml
    expect(out + err).to include('RSpec::OpenAPI got errors building 1 requests')
    expect(out + err).to include('type detection is not implemented for')
  end
end
