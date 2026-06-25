# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

RSpec.describe 'SharedExtractor.normalize_example_mode' do
  # Reset the once-per-process flag directly via the ivar instead of exposing a
  # test-only API on the production class.
  before { SharedExtractor.instance_variable_set(:@warned_example_mode_multiple_shorthand, false) }

  it 'defaults to :single for both request and response when value is nil' do
    expect(SharedExtractor.normalize_example_mode(nil)).to eq([:single, :single])
  end

  it 'maps bare :single to both sides' do
    expect(SharedExtractor.normalize_example_mode(:single)).to eq([:single, :single])
  end

  it 'maps bare :none to both sides' do
    expect(SharedExtractor.normalize_example_mode(:none)).to eq([:none, :none])
  end

  it 'treats bare :multiple as the back-compat shorthand { request: :single, response: :multiple }' do
    result = nil
    expect { result = SharedExtractor.normalize_example_mode(:multiple) }
      .to output(/DEPRECATION/).to_stderr
    expect(result).to eq([:single, :multiple])
  end

  it 'emits the deprecation warning only once per process' do
    expect { 3.times { SharedExtractor.normalize_example_mode(:multiple) } }
      .to output(a_string_including('DEPRECATION').and(satisfy { |s| s.scan('DEPRECATION').size == 1 }))
      .to_stderr
  end

  it 'does not warn for the explicit hash form' do
    expect { SharedExtractor.normalize_example_mode(request: :multiple, response: :multiple) }
      .not_to output.to_stderr
  end

  it 'reads :request and :response from the hash form' do
    result = SharedExtractor.normalize_example_mode(request: :multiple, response: :none)
    expect(result).to eq([:multiple, :none])
  end

  it 'defaults missing hash keys to :single' do
    expect(SharedExtractor.normalize_example_mode(request: :multiple)).to eq([:multiple, :single])
    expect(SharedExtractor.normalize_example_mode(response: :multiple)).to eq([:single, :multiple])
  end

  it 'accepts string keys in the hash form' do
    expect(SharedExtractor.normalize_example_mode('request' => 'multiple', 'response' => 'none'))
      .to eq([:multiple, :none])
  end

  it 'raises on invalid bare value' do
    expect { SharedExtractor.normalize_example_mode(:bogus) }.to raise_error(ArgumentError, /example_mode/)
  end

  it 'raises on invalid hash value' do
    expect { SharedExtractor.normalize_example_mode(request: :bogus) }.to raise_error(ArgumentError, /example_mode/)
  end

  it 'raises on unsupported types' do
    expect { SharedExtractor.normalize_example_mode(123) }.to raise_error(ArgumentError, /example_mode/)
  end
end

RSpec.describe 'SharedExtractor.merge_openapi_metadata' do
  describe 'nested context that overrides :openapi', openapi: { summary: 'List things', operation_id: 'listThings' } do
    context 'inner', openapi: { description: 'an edge case' } do
      it "recovers the ancestor's summary and operation_id" do
        merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
        expect(merged[:summary]).to eq('List things')
        expect(merged[:operation_id]).to eq('listThings')
        expect(merged[:description]).to eq('an edge case')
      end
    end
  end

  describe 'key declared at multiple levels', openapi: { summary: 'outer', tags: ['Things'] } do
    context 'inner', openapi: { summary: 'inner' } do
      it 'lets the nearest level win while recovering ancestor-only keys' do
        merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
        expect(merged[:summary]).to eq('inner')
        expect(merged[:tags]).to eq(['Things'])
      end
    end
  end

  describe 'example-level override', openapi: { summary: 'from group' } do
    it "lets the example's own :openapi win over its group", openapi: { summary: 'from example' } do
      merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
      expect(merged[:summary]).to eq('from example')
    end
  end

  describe 'no nested override', openapi: { summary: 'S' } do
    it 'is a no-op' do
      expect(SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)).to eq(summary: 'S')
    end
  end

  describe 'overrides several levels deep', openapi: { summary: 'List things' } do
    context 'middle', openapi: { tags: ['Things'] } do
      context 'inner', openapi: { description: 'edge' } do
        it 'recovers keys from every ancestor level, not just the immediate parent' do
          merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
          expect(merged[:summary]).to eq('List things') # two parent hops up
          expect(merged[:tags]).to eq(['Things']) # one parent hop up
          expect(merged[:description]).to eq('edge') # immediate
        end
      end
    end
  end

  # Group metadata lacks :example_group, exercising the :parent_example_group
  # fallback. Synthetic hash avoids the deprecated :example_group alias.
  describe 'group metadata input (no :example_group key)' do
    it 'falls back to :parent_example_group and recovers every ancestor level' do
      root_group = { openapi: { summary: 'List things', operation_id: 'listThings' } }
      inner_group = { openapi: { description: 'an edge case' }, parent_example_group: root_group }
      merged = SharedExtractor.merge_openapi_metadata(inner_group)
      expect(merged).to eq(summary: 'List things', operation_id: 'listThings', description: 'an edge case')
    end
  end

  describe 'a nearer level re-declaring keys an ancestor also set',
           openapi: { summary: 'outer summary', tags: ['Outer'], operation_id: 'outer_op' } do
    context 'inner', openapi: { tags: ['Inner'], operation_id: 'inner_op' } do
      it 'replaces structured keys wholesale, last-wins for scalars, recovers ancestor-only keys' do
        merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
        expect(merged[:tags]).to eq(['Inner'])          # replaced wholesale, not ['Outer', 'Inner']
        expect(merged[:operation_id]).to eq('inner_op') # nearest scalar wins
        expect(merged[:summary]).to eq('outer summary') # ancestor-only key recovered
      end
    end
  end

  describe 'example-level override across a multi-level ancestry',
           openapi: { summary: 'from grandparent', tags: ['Things'] } do
    context 'middle', openapi: { operation_id: 'from_parent' } do
      it 'lets the example win over every ancestor yet recovers ancestor-only keys',
         openapi: { summary: 'from example' } do
        merged = SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)
        expect(merged[:summary]).to eq('from example')     # example beats grandparent
        expect(merged[:operation_id]).to eq('from_parent') # recovered from middle group
        expect(merged[:tags]).to eq(['Things'])            # recovered from grandparent
      end
    end
  end

  describe 'no :openapi metadata anywhere' do
    it 'returns an empty hash' do
      expect(SharedExtractor.merge_openapi_metadata(RSpec.current_example.metadata)).to eq({})
    end
  end
end
