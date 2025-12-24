# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SharedExtractor do
  describe '.normalize_example_mode' do
    it 'defaults to :single for nil' do
      expect(described_class.normalize_example_mode(nil)).to eq(:single)
    end

    it 'accepts string values' do
      expect(described_class.normalize_example_mode('multiple')).to eq(:multiple)
    end

    it 'accepts symbol values' do
      expect(described_class.normalize_example_mode(:none)).to eq(:none)
    end

    it 'normalizes string values' do
      expect(described_class.normalize_example_mode('  SINGLE ')).to eq(:single)
    end

    it 'raises for invalid values' do
      expect do
        described_class.normalize_example_mode('invalid')
      end.to raise_error(ArgumentError, /example_mode must be one of/)
    end

    it 'raises for invalid types' do
      expect do
        described_class.normalize_example_mode(123)
      end.to raise_error(ArgumentError, /example_mode must be one of/)
    end
  end
end
