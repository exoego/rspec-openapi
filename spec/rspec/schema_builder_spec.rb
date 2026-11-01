# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'schema builder spec' do
  describe 'additionalProperties on objects merged across sibling array items' do
    def meta_schema(additional_properties)
      record = RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/products', path_params: {}, query_params: {}, request_headers: [],
        status: 200, response_body: { products: [{ meta: { a: 1 } }, { meta: { b: 'x' } }] }, response_headers: [],
        response_content_type: 'application/json', response_example_mode: :none,
        response_additional_properties: additional_properties,
      )
      schema = RSpec::OpenAPI::SchemaBuilder.build(record)
      schema.dig(:paths, :'/products', :get, :responses, :'200', :content, :'application/json', :schema,
                 :properties, :products, :items, :properties, :meta,)
    end

    it 'keeps a boolean additionalProperties on the merged object' do
      expect(meta_schema({ 'products.meta' => false })).to eq(
        type: 'object',
        properties: { a: { type: 'integer', nullable: true }, b: { type: 'string', nullable: true } },
        required: [],
        additionalProperties: false,
      )
    end

    it 'keeps a dictionary schema without inventing empty properties' do
      expect(meta_schema({ 'products.meta' => { type: 'string' } }))
        .to eq(type: 'object', additionalProperties: { type: 'string' })
    end
  end
end
