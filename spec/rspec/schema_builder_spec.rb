# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

RSpec.describe RSpec::OpenAPI::SchemaBuilder do
  describe '.adjust_params (private)' do
    subject { described_class.send(:adjust_params, input) }

    context 'with array of primitive strings' do
      let(:input) { { 'tags' => %w[ruby rails] } }

      it { is_expected.to eq({ 'tags' => %w[ruby rails] }) }
    end

    context 'with nested hash containing array of integers' do
      let(:input) { { 'filters' => { 'ids' => [1, 2, 3] } } }

      it { is_expected.to eq({ 'filters' => { 'ids' => [1, 2, 3] } }) }
    end
  end

  describe '.build_type (private)' do
    subject { described_class.send(:build_type, input, **options) }

    let(:options) { {} }

    context 'with String' do
      let(:input) { 'hello' }

      it { is_expected.to eq({ type: 'string' }) }
    end

    context 'with Integer' do
      let(:input) { 42 }

      it { is_expected.to eq({ type: 'integer' }) }
    end

    context 'with Float' do
      let(:input) { 3.14 }

      it { is_expected.to eq({ type: 'number', format: 'float' }) }
    end

    context 'with TrueClass' do
      let(:input) { true }

      it { is_expected.to eq({ type: 'boolean' }) }
    end

    context 'with FalseClass' do
      let(:input) { false }

      it { is_expected.to eq({ type: 'boolean' }) }
    end

    context 'with Array' do
      let(:input) { [] }

      it { is_expected.to eq({ type: 'array' }) }
    end

    context 'with Hash' do
      let(:input) { {} }

      it { is_expected.to eq({ type: 'object' }) }
    end

    context 'with NilClass' do
      let(:input) { nil }

      it { is_expected.to eq({ nullable: true }) }
    end

    context 'with explicit format option' do
      let(:input) { '2024-01-01' }
      let(:options) { { format: 'date-time' } }

      it { is_expected.to eq({ type: 'string', format: 'date-time' }) }
    end

    context 'with unhandled type' do
      let(:input) { :symbol }

      it 'raises NotImplementedError' do
        expect { subject }.to raise_error(NotImplementedError, /type detection is not implemented/)
      end
    end
  end
end
