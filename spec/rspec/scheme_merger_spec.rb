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

  describe 'parameter optionality across test cases' do
    it 'keeps required: true when the same parameter appears in both specs' do
      base = {
        parameters: [
          { name: 'X-Auth', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'X-Auth', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to eq([
                                          { name: 'X-Auth', in: 'header', required: true, schema: { type: 'string' } },
                                        ])
    end

    it 'demotes a header that is missing from the new spec to required: false' do
      base = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
          { name: 'X-Bar', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
        { name: 'X-Bar', in: 'header', required: false, schema: { type: 'string' } },
      )
    end

    it 'demotes a newly appearing header to required: false' do
      # Newly appearing parameters are also treated as optional — they were
      # missing in earlier test cases. Headers have no metadata to express
      # "explicit required" intent, so the default-`required: true` is overridden.
      base = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
          { name: 'X-Bar', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
        { name: 'X-Bar', in: 'header', required: false, schema: { type: 'string' } },
      )
    end

    it 'preserves a newly appearing query param when explicitly marked via required_request_params' do
      # The schema_builder only sets `required: true` on query params listed in
      # `required_request_params`, so a value-only query with `required: true`
      # signals explicit user intent and is respected.
      base = {
        parameters: [
          { name: 'page', in: 'query', required: false, schema: { type: 'integer' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'page', in: 'query', required: false, schema: { type: 'integer' } },
          { name: 'limit', in: 'query', required: true, schema: { type: 'integer' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'page', in: 'query', required: false, schema: { type: 'integer' } },
        { name: 'limit', in: 'query', required: true, schema: { type: 'integer' } },
      )
    end

    it 'keeps optional once a parameter has been observed missing (optional propagation)' do
      # Simulates 3 test cases where X-Bar appears in cases 1 and 3 but is missing in case 2.
      # After case 2 demotes X-Bar to optional, case 3's `required: true` should NOT undo it.
      base = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
          { name: 'X-Bar', in: 'header', required: false, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
          { name: 'X-Bar', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'X-Foo', in: 'header', required: true, schema: { type: 'string' } },
        { name: 'X-Bar', in: 'header', required: false, schema: { type: 'string' } },
      )
    end

    it 'demotes query parameters the same way' do
      base = {
        parameters: [
          { name: 'page', in: 'query', required: true, schema: { type: 'integer' } },
          { name: 'filter', in: 'query', required: true, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'page', in: 'query', required: true, schema: { type: 'integer' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'page', in: 'query', required: true, schema: { type: 'integer' } },
        { name: 'filter', in: 'query', required: false, schema: { type: 'string' } },
      )
    end

    it 'keeps path parameters required even if missing from one spec' do
      base = {
        parameters: [
          { name: 'id', in: 'path', required: true, schema: { type: 'integer' } },
          { name: 'X-Auth', in: 'header', required: true, schema: { type: 'string' } },
        ],
      }
      spec = {
        parameters: [
          { name: 'id', in: 'path', required: true, schema: { type: 'integer' } },
        ],
      }

      result = RSpec::OpenAPI::SchemaMerger.merge!(base, spec)

      expect(result[:parameters]).to contain_exactly(
        { name: 'id', in: 'path', required: true, schema: { type: 'integer' } },
        { name: 'X-Auth', in: 'header', required: false, schema: { type: 'string' } },
      )
    end
  end
end
