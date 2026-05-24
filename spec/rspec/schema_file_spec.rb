# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe RSpec::OpenAPI::SchemaFile do
  describe '#edit' do
    let(:tempfile) { Tempfile.new(['schema', extname]) }
    let(:path) { tempfile.path }

    after { tempfile.close! }

    {
      '.yaml' => YAML.method(:safe_load),
      '.json' => JSON.method(:parse),
    }.each do |ext, parser|
      context "with an empty #{ext} file" do
        let(:extname) { ext }

        it 'treats the contents as an empty hash instead of crashing' do
          tempfile.close

          captured = nil
          described_class.new(path).edit do |spec|
            captured = spec.dup
            spec[:openapi] = '3.0.0'
          end

          expect(captured).to eq({})
          expect(parser.call(File.read(path))).to eq('openapi' => '3.0.0')
        end
      end
    end
  end
end
