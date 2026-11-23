# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'schema builder spec' do
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
    let(:merger) { RSpec::OpenAPI::SchemaBuilder.singleton_class.const_get(:VariationMerger) }

    # Fresh objects each time, so an expectation never shares one with the input.
    def array_enum
      [[], ['new'], ['sale']]
    end

    def string_array(**keys)
      { type: 'array', items: { type: 'string' }, **keys }
    end

    def response_properties(body, enum = nil)
      record = RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/products', path_params: {}, query_params: {}, request_headers: [],
        status: 200, response_headers: [], response_content_type: 'application/json',
        response_example_mode: :none, response_body: body, response_enum: enum,
      )
      RSpec::OpenAPI::SchemaBuilder.build(record).dig(
        :paths, :'/products', :get, :responses, :'200', :content, :'application/json', :schema, :properties,
      )
    end

    def tags_schema(item_count)
      body = { groups: [{ tags: ['new'] }, { tags: ['sale'] }].first(item_count) }
      response_properties(body, { 'groups.tags' => array_enum }).dig(:groups, :items, :properties, :tags)
    end

    it 'keeps the array enum with one or multiple sibling items, after the type' do
      [1, 2].each do |item_count|
        expect(tags_schema(item_count)).to eq(string_array(enum: array_enum))
        expect(tags_schema(item_count).keys).to eq([:type, :enum, :items])
      end
    end

    it 'keeps the type first when a nullable array merges across siblings' do
      rows = [{ list: [{ c: [1] }, { c: nil }] }, { list: [{ c: [2] }, { c: nil }] }]
      c = response_properties({ rows: rows }).dig(:rows, :items, :properties, :list, :items, :properties, :c)

      expect(c.keys).to eq([:type, :items, :nullable])
    end

    it 'keeps common keywords while merging empty and populated items' do
      annotated = -> { string_array(enum: array_enum, uniqueItems: false, default: nil) }
      variations = [annotated.call, annotated.call.merge(items: {})]

      variations.permutation.each do |schemas|
        expect(merger.merge_variations(schemas)).to eq(annotated.call)
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

    it 'keeps an enum of whole arrays on the array, not its items' do
      operation = build(response_body: { tags: ['new'] }, response_enum: { 'tags' => [[], ['new']] })

      expect(operation.dig(:responses, :'200', :content, :'application/json', :schema, :properties, :tags))
        .to eq(type: 'array', enum: [[], ['new']], items: { type: 'string' })
    end
  end

  describe 'arrays merged across sibling array items when one already has a oneOf' do
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

    it 'keeps nullable carried only by an integer variation that a number widens away' do
      expect(path_items_schema([[1, nil], [2.5], ['a', true]]))
        .to eq(oneOf: [{ type: 'boolean' }, { type: 'number', format: 'float' }, { type: 'string' }], nullable: true)
    end

    it 'merges object alternatives into one' do
      expect(path_items_schema([[{ a: 1 }, true], [{ b: 'x' }]])).to eq(
        oneOf: [
          { type: 'boolean' },
          {
            type: 'object',
            properties: { a: { type: 'integer', nullable: true }, b: { type: 'string', nullable: true } },
            required: [],
          },
        ],
      )
    end

    it 'merges array alternatives into one so a recorded array matches exactly one' do
      expect(path_items_schema([[[1], true], [[2.5]]]))
        .to eq(oneOf: [{ type: 'array', items: { type: 'number', format: 'float' } }, { type: 'boolean' }])
    end

    it 'keeps nullable on the items of merged array alternatives' do
      expect(path_items_schema([[[1, nil], true], [['s']]])).to eq(
        oneOf: [
          { type: 'array', items: { oneOf: [{ type: 'integer' }, { type: 'string' }], nullable: true } },
          { type: 'boolean' },
        ],
      )
    end

    it 'merges an existing oneOf property across sibling objects without overlapping alternatives' do
      expect(path_items_schema([[{ v: 1 }, { v: 'a' }], [{ v: 2.5 }]]).dig(:properties, :v))
        .to eq(oneOf: [{ type: 'number', format: 'float' }, { type: 'string' }])
    end
  end

  describe 'nullable scalar arrays merged across sibling array items' do
    it 'keeps nullable when a number widens away the nullable integer' do
      expect(path_items_schema([[1, nil], [2.5]])).to eq(type: 'number', format: 'float', nullable: true)
    end

    it 'keeps nullable whichever sibling carries it' do
      expect(path_items_schema([['a'], ['b', nil]])).to eq(type: 'string', nullable: true)
      expect(path_items_schema([['b', nil], ['a']])).to eq(type: 'string', nullable: true)
    end

    it 'keeps nullable when divergent types become a oneOf' do
      expect(path_items_schema([['a', nil], [true]]))
        .to eq(oneOf: [{ type: 'boolean' }, { type: 'string' }], nullable: true)
    end
  end
end
