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

    it 'normalize keys to symbol' do
      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)
      expect(result).to eq({
                             n: 1,
                             required: [],
                             a: {
                               b1: 1,
                               b2: %w[foo bar],
                               b3: {
                                 c1: 2,
                                 c2: 3,
                               },
                             },
                           })
    end
  end

  describe 'migration from properties to additionalProperties' do
    it 'removes stale properties/required when the new spec introduces additionalProperties' do
      base = {
        type: 'object',
        properties: {
          can_do_thing: { type: 'boolean' },
          can_do_other_thing: { type: 'boolean' },
        },
        required: %i[can_do_thing can_do_other_thing],
      }
      spec = {
        type: 'object',
        additionalProperties: { type: 'boolean' },
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result).to eq(
        type: 'object',
        additionalProperties: { type: 'boolean' },
      )
    end

    it 'preserves manually-edited hybrid schemas that already declare additionalProperties' do
      base = {
        type: 'object',
        properties: { id: { type: 'integer' } },
        required: [:id],
        additionalProperties: { type: 'string' },
      }
      spec = {
        type: 'object',
        additionalProperties: { type: 'string' },
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result).to eq(
        type: 'object',
        properties: { id: { type: 'integer' } },
        required: [:id],
        additionalProperties: { type: 'string' },
      )
    end

    it 'still skips adding properties/required when base already has additionalProperties' do
      base = {
        type: 'object',
        additionalProperties: { type: 'boolean' },
      }
      spec = {
        type: 'object',
        properties: { foo: { type: 'boolean' } },
        required: [:foo],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result).to eq(
        type: 'object',
        additionalProperties: { type: 'boolean' },
      )
    end

    it 'prunes nested properties when additionalProperties is introduced one level deep' do
      base = {
        type: 'object',
        properties: {
          data: {
            type: 'object',
            properties: {
              can_edit: { type: 'boolean' },
              can_delete: { type: 'boolean' },
            },
            required: %i[can_edit can_delete],
          },
        },
        required: [:data],
      }
      spec = {
        type: 'object',
        properties: {
          data: {
            type: 'object',
            additionalProperties: { type: 'boolean' },
          },
        },
        required: [:data],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result).to eq(
        type: 'object',
        properties: {
          data: {
            type: 'object',
            additionalProperties: { type: 'boolean' },
          },
        },
        required: [:data],
      )
    end
  end
end
