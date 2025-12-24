# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

RSpec.describe SharedExtractor do
  describe '.normalize_example_mode' do
    subject { described_class.normalize_example_mode(value, example) }

    let(:example) { nil }

    context 'with nil' do
      let(:value) { nil }

      it { is_expected.to eq(:single) }
    end

    context 'with string "multiple"' do
      let(:value) { 'multiple' }

      it { is_expected.to eq(:multiple) }
    end

    context 'with symbol :none' do
      let(:value) { :none }

      it { is_expected.to eq(:none) }
    end

    context 'with padded uppercase string' do
      let(:value) { '  SINGLE ' }

      it { is_expected.to eq(:single) }
    end

    context 'with invalid string value' do
      let(:value) { 'invalid' }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, /example_mode must be one of/)
      end
    end

    context 'with invalid type (Integer)' do
      let(:value) { 123 }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, /example_mode must be one of/)
      end
    end

    context 'with invalid symbol and example context' do
      let(:value) { :invalid }
      let(:example) { double('RSpec::Core::Example', full_description: 'GET /users returns list') }

      it 'includes example description in error' do
        expect { subject }.to raise_error(ArgumentError, %r{\(example: GET /users returns list\)})
      end
    end

    context 'with invalid type (Array) and example context' do
      let(:value) { [1, 2, 3] }
      let(:example) { double('RSpec::Core::Example', full_description: 'POST /items creates item') }

      it 'includes example description in error' do
        expect { subject }.to raise_error(ArgumentError, %r{\(example: POST /items creates item\)})
      end
    end
  end
end
