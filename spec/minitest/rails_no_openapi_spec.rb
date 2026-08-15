# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails integration minitest, without OpenAPI generation' do
  include SpecHelper

  describe 'with disabled OpenAPI generation' do
    it 'can run tests' do
      minitest 'spec/integration_tests/rails_test.rb'
    end
  end
end
