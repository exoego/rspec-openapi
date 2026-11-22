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

  describe 'scalar arrays merged across sibling array items when one already has a oneOf' do
    def path_items_schema(paths)
      record = RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/nodes', path_params: {}, query_params: {}, request_headers: [],
        status: 200, response_body: { nodes: paths.map { |path| { path: path } } }, response_headers: [],
        response_content_type: 'application/json', response_example_mode: :none,
      )
      schema = RSpec::OpenAPI::SchemaBuilder.build(record)
      schema.dig(:paths, :'/nodes', :get, :responses, :'200', :content, :'application/json', :schema,
                 :properties, :nodes, :items, :properties, :path, :items,)
    end

    it 'keeps the oneOf instead of taking the first variation' do
      expect(path_items_schema([['user', 'details'], ['billing', true]]))
        .to eq(oneOf: [{ type: 'boolean' }, { type: 'string' }])
    end

    it 'widens integer alternatives when a number alternative is present' do
      expect(path_items_schema([[1, 'x'], [2.5]]))
        .to eq(oneOf: [{ type: 'number', format: 'float' }, { type: 'string' }])
    end

    it 'keeps nullable when a merged variation is nullable' do
      expect(path_items_schema([['user', nil], ['billing', true]]))
        .to eq(oneOf: [{ type: 'boolean' }, { type: 'string' }], nullable: true)
    end

    it 'merges array alternatives into one so a recorded array matches exactly one' do
      expect(path_items_schema([[[1], true], [[2.5]]]))
        .to eq(oneOf: [{ type: 'array', items: { type: 'number', format: 'float' } }, { type: 'boolean' }])
    end
  end
end
