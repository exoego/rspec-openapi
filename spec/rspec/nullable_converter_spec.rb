# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'nullable oneOf per OpenAPI version' do
  around do |example|
    original = RSpec::OpenAPI.openapi_version
    example.run
  ensure
    RSpec::OpenAPI.openapi_version = original
  end

  def written_schema(version, schema)
    RSpec::OpenAPI.openapi_version = version
    response = { content: { 'application/json': { schema: schema } } }
    doc = { paths: { '/flags': { get: { responses: { '200': response } } } } }
    RSpec::OpenAPI::ResultRecorder.new({}).send(:cleanup_schema!, Marshal.load(Marshal.dump(doc)), doc)
    doc.dig(:paths, :'/flags', :get, :responses, :'200', :content, :'application/json', :schema)
  end

  let(:nullable_one_of) { { oneOf: [{ type: 'boolean' }, { type: 'string' }], nullable: true } }

  it 'keeps nullable: true on the oneOf for 3.0' do
    expect(written_schema('3.0.3', nullable_one_of)).to eq(nullable_one_of)
  end

  it 'adds null as its own variant, in type order, for 3.1+' do
    expect(written_schema('3.1.0', nullable_one_of))
      .to eq(oneOf: [{ type: 'boolean' }, { type: 'null' }, { type: 'string' }])
  end

  it 'reads a null variant back as nullable so the next run merges it as before' do
    written = written_schema('3.2.0', nullable_one_of)

    expect(RSpec::OpenAPI::NullableConverter.normalize!(written)).to eq(nullable_one_of)
  end
end
