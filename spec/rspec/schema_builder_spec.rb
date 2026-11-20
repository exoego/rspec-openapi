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

  describe 'array-level keys merged across variations' do
    let(:array_enum) { [[], ['new'], ['sale']] }
    let(:string_array) { { type: 'array', items: { type: 'string' } } }
    let(:merger) { RSpec::OpenAPI::SchemaBuilder.singleton_class.const_get(:VariationMerger) }

    def tags_schema(item_count)
      record = RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/products', path_params: {}, query_params: {}, request_headers: [],
        status: 200, response_headers: [], response_content_type: 'application/json',
        response_example_mode: :none,
        response_body: { groups: [{ tags: ['new'] }, { tags: ['sale'] }].first(item_count) },
        response_enum: { 'groups.tags' => array_enum },
      )
      RSpec::OpenAPI::SchemaBuilder.build(record).dig(
        :paths, :'/products', :get, :responses, :'200', :content, :'application/json', :schema,
        :properties, :groups, :items, :properties, :tags,
      )
    end

    it 'keeps the array enum with one or multiple sibling items' do
      [1, 2].each do |item_count|
        expect(tags_schema(item_count)).to include(type: 'array', enum: array_enum)
        expect(tags_schema(item_count).dig(:items, :type)).to eq('string')
      end
    end

    it 'keeps common keywords while merging empty and populated items' do
      annotated = string_array.merge(enum: array_enum, uniqueItems: false, default: nil)
      variations = [annotated, annotated.merge(items: {})]

      variations.permutation.each do |schemas|
        expect(merger.merge_variations(schemas)).to eq(annotated)
      end
    end

    it 'drops conflicting enums in either order' do
      variations = [
        string_array.merge(enum: [['new']]),
        string_array.merge(enum: [['sale']]),
      ]

      variations.permutation.each do |schemas|
        expect(merger.merge_variations(schemas)).to eq(string_array)
      end
    end

    it 'drops keywords missing from one variation in either order' do
      variations = [
        string_array.merge(enum: array_enum, uniqueItems: false, default: nil),
        string_array,
      ]

      variations.permutation.each do |schemas|
        expect(merger.merge_variations(schemas)).to eq(string_array)
      end
    end
  end
end
