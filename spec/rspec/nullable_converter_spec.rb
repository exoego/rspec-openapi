# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::OpenAPI::NullableConverter do
  describe 'round-trip of multi-type schemas' do
    it 'keeps the type array flat when several non-null types are nullable' do
      schema = {
        type: ['string', 'number', 'boolean', 'object', 'array', 'null'],
      }

      described_class.normalize!(schema)
      expect(schema).to eq(
        type: ['string', 'number', 'boolean', 'object', 'array'],
        nullable: true,
      )

      described_class.to_json_schema!(schema)
      expect(schema).to eq(
        type: ['string', 'number', 'boolean', 'object', 'array', 'null'],
      )
    end
  end

  describe '.to_json_schema!' do
    it 'appends null to a multi-type array instead of nesting it' do
      schema = {
        type: ['string', 'integer'],
        nullable: true,
      }

      described_class.to_json_schema!(schema)

      expect(schema[:type]).to eq(['string', 'integer', 'null'])
    end

    it 'wraps a scalar type as before' do
      schema = {
        type: 'string',
        nullable: true,
      }

      described_class.to_json_schema!(schema)

      expect(schema[:type]).to eq(['string', 'null'])
    end

    it 'uses the null type alone when the schema had no type' do
      schema = {
        nullable: true,
      }

      described_class.to_json_schema!(schema)

      expect(schema[:type]).to eq('null')
    end

    it 'does not duplicate null when already present' do
      schema = {
        type: ['string', 'null'],
        nullable: true,
      }

      described_class.to_json_schema!(schema)

      expect(schema[:type]).to eq(['string', 'null'])
    end
  end
end
