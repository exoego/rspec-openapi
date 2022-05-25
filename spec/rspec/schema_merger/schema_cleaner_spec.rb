require 'spec_helper'
require 'json'
require 'rspec/openapi/schema_cleaner'

RSpec.describe 'SchemaCleaner' do
  include SpecHelper

  describe 'paths_to_all_fields' do
    it 'returns every paths to fields in the given Hash' do
      expect(RSpec::OpenAPI::SchemaCleaner.paths_to_all_fields({}))
        .to eq([])
      expect(RSpec::OpenAPI::SchemaCleaner.paths_to_all_fields({ 'paths' => {} }))
        .to eq([['paths']])
      expect(RSpec::OpenAPI::SchemaCleaner.paths_to_all_fields({ 'paths' => { 'a' => 1 } }))
        .to eq([['paths'], %w[paths a]])
      expect(RSpec::OpenAPI::SchemaCleaner.paths_to_all_fields({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }))
        .to eq([['paths'], %w[paths a], %w[paths b], %w[paths c], %w[paths c d]])
    end
  end

  describe 'matched_paths' do
    describe 'full-path' do
      it 'returns the exact path to the field' do
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'foo' => {} }, 'paths'))
          .to eq([])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => {} }, 'paths.a'))
          .to eq([])

        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1 } }, 'paths'))
          .to eq([['paths']])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths'))
          .to eq([['paths']])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1 } }, 'paths.a'))
          .to eq([%w[paths a]])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths.a'))
          .to eq([%w[paths a]])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths.c.d'))
          .to eq([%w[paths c d]])
      end
    end

    describe 'wildcard(*)' do
      it 'returns possible paths to the fields' do
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({}, 'paths.*'))
          .to eq([])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => {} }, 'paths.*'))
          .to eq([])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1 } }, 'paths.*'))
          .to eq([%w[paths a]])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths.*'))
          .to eq([%w[paths a], %w[paths b], %w[paths c]])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths.*.*'))
          .to eq([%w[paths c d]])
        expect(RSpec::OpenAPI::SchemaCleaner.matched_paths({ 'paths' => { 'a' => 1, 'b' => 2, 'c' => { 'd' => 1 } } }, 'paths.*.*.*'))
          .to eq([])
      end
    end
  end

  describe('cleanup_hash!') do
    it 'deletes fields which matches the given selector and not in other hash' do
      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_hash!(
        { 'paths' => { 'a' => 1 }, 'info' => 'hello' },
        { 'other' => {} },
        'paths')).to eq({ 'info' => 'hello' })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_hash!(
        { 'paths' => { 'a' => 1 } },
        { 'paths' => {} },
        'paths')).to eq({ 'paths' => { 'a' => 1 } })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_hash!(
        { 'paths' => { 'a' => 1, 'b' => 1 } },
        { 'no' => {} },
        'paths.a')).to eq({ 'paths' => { 'b' => 1 } })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_hash!(
        { 'paths' => { 'a' => 1, 'b' => 2 } },
        { 'paths' => { 'b' => 2 } },
        'paths.*')).to eq({ 'paths' => { 'b' => 2 } })
    end
  end

  describe('cleanup_array!') do
    it 'delete hashes in array if the hash is not in the corresponding array in other hash' do
      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
        { 'paths' => [{ 'a' => 1 }, { 'b' => 1 }] },
        { 'paths' => [] },
        'paths')).to eq({ 'paths' => [] })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
        { 'paths' => [{ 'a' => 1 }, { 'b' => 1 }] },
        { 'paths' => [{ 'a' => 1 }] },
        'paths')).to eq({ 'paths' => [{ 'a' => 1 }] })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
        { 'paths' => [{ 'a' => 1 }, { 'b' => 1 }] },
        { 'paths' => [{ 'a' => 42 }] }, # value is different
        'paths')).to eq({ 'paths' => [] })

      expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
        { 'paths' => [{ 'a' => 1 }, { 'b' => 1 }] },
        { 'paths' => [{ 'a' => 1, 'other' => 42 }] }, # other key exists
        'paths')).to eq({ 'paths' => [] })
    end

    describe 'specific keys' do
      it 'compares hashes in array only by the given keys' do
        expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
          { 'paths' => [{ 'a' => 1, 'b' => 1 }, { 'a' => 42 }] },
          { 'paths' => [{ 'a' => 1 }] },
          'paths',
          ['a'])).to eq({ 'paths' => [{ 'a' => 1, 'b' => 1 }] })

        expect(RSpec::OpenAPI::SchemaCleaner.cleanup_array!(
          { 'paths' => [{ 'b' => 1, 'a' => 1 }, { 'a' => 42 }] },
          { 'paths' => [{ 'a' => 1, 'b' => 1, 'other' => 42 }] },
          'paths',
          %w[a b])).to eq({ 'paths' => [{ 'a' => 1, 'b' => 1 }] })
      end
    end
  end
end
