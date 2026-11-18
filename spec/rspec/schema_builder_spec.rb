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

  describe 'enum on an array of scalars' do
    def build(**attributes)
      record = RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/products', path_params: {}, query_params: {}, request_headers: [],
        status: 200, response_body: {}, response_headers: [], required_request_params: [],
        response_content_type: 'application/json', response_example_mode: :none, **attributes,
      )
      RSpec::OpenAPI::SchemaBuilder.build(record).dig(:paths, :'/products', :get)
    end

    it 'puts a request enum on the items of an array query param, not on the array' do
      operation = build(query_params: { 'sort' => ['-name'] }, request_enum: { 'sort' => ['name', '-name'] })

      expect(operation[:parameters].first[:schema])
        .to eq(type: 'array', items: { type: 'string', enum: ['name', '-name'] })
    end

    it 'puts a response enum on the items of an array property, not on the array' do
      operation = build(response_body: { tags: ['new'] }, response_enum: { 'tags' => ['new', 'sale'] })

      expect(operation.dig(:responses, :'200', :content, :'application/json', :schema, :properties, :tags))
        .to eq(type: 'array', items: { type: 'string', enum: ['new', 'sale'] })
    end
  end
end
