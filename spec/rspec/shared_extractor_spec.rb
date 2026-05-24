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
