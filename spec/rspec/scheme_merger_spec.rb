# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'schema merger spec' do
  include SpecHelper

  describe 'mixed symbol and strings' do
    let(:base) do
      {
        'n' => 1,
        'required' => %w[foo bar],
        'a' => {
          b1: 1,
          b2: %w[foo bar],
          'b3' => {
            'c1' => 2,
            c2: 3,
          },
        },
      }
    end

    let(:spec) do
      {
        n: 1,
        required: ['buz'],
        a: {
          'b1' => 1,
          'b2' => %w[foo bar],
          b3: {
            c1: 2,
            'c2' => 3,
          },
        },
      }
    end

    it 'normalize symbol to string' do
      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)
      expect(result).to eq({
                             'n' => 1,
                             'required' => [],
                             'a' => {
                               'b1' => 1,
                               'b2' => %w[foo bar],
                               'b3' => {
                                 'c1' => 2,
                                 'c2' => 3,
                               },
                             },
                           })
    end
  end
end
