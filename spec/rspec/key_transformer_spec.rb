# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

RSpec.describe RSpec::OpenAPI::KeyTransformer do
  describe '.symbolize' do
    subject { described_class.symbolize(input) }

    context 'with simple hash' do
      let(:input) { { 'key' => 'value' } }

      it { is_expected.to eq({ key: 'value' }) }
    end

    context 'with nested hash' do
      let(:input) { { 'outer' => { 'inner' => 'value' } } }

      it { is_expected.to eq({ outer: { inner: 'value' } }) }
    end

    context 'with :examples key' do
      let(:input) { { 'examples' => { 'Test Name' => { 'value' => 'data' } } } }

      it { is_expected.to eq({ examples: { test_name: { value: 'data' } } }) }
    end

    context 'with array of hashes' do
      let(:input) { [{ 'a' => 1 }, { 'b' => 2 }] }

      it { is_expected.to eq([{ a: 1 }, { b: 2 }]) }
    end

    context 'with string' do
      let(:input) { 'string' }

      it { is_expected.to eq('string') }
    end

    context 'with integer' do
      let(:input) { 123 }

      it { is_expected.to eq(123) }
    end

    context 'with nil' do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.symbolize_examples' do
    subject { described_class.symbolize_examples(input) }

    context 'with hash having spaced keys' do
      let(:input) { { 'Test Name' => { 'value' => 'data' } } }

      it { is_expected.to eq({ test_name: { value: 'data' } }) }
    end

    context 'with nested values' do
      let(:input) { { 'Example' => { 'nested' => { 'key' => 'value' } } } }

      it { is_expected.to eq({ example: { nested: { key: 'value' } } }) }
    end

    context 'with array of hashes' do
      let(:input) { [{ 'a' => 1 }, { 'b' => 2 }] }

      it { is_expected.to eq([{ a: 1 }, { b: 2 }]) }
    end

    context 'with string' do
      let(:input) { 'string' }

      it { is_expected.to eq('string') }
    end

    context 'with integer' do
      let(:input) { 123 }

      it { is_expected.to eq(123) }
    end

    context 'with nil' do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.stringify' do
    subject { described_class.stringify(input) }

    context 'with simple hash' do
      let(:input) { { key: 'value' } }

      it { is_expected.to eq({ 'key' => 'value' }) }
    end

    context 'with nested hash' do
      let(:input) { { outer: { inner: 'value' } } }

      it { is_expected.to eq({ 'outer' => { 'inner' => 'value' } }) }
    end

    context 'with array of hashes' do
      let(:input) { [{ a: 1 }, { b: 2 }] }

      it { is_expected.to eq([{ 'a' => 1 }, { 'b' => 2 }]) }
    end

    context 'with string' do
      let(:input) { 'string' }

      it { is_expected.to eq('string') }
    end

    context 'with integer' do
      let(:input) { 123 }

      it { is_expected.to eq(123) }
    end

    context 'with nil' do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end
  end
end
