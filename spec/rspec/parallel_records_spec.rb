# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::OpenAPI::ParallelRecords do
  let(:record) { RSpec::OpenAPI::Record.new(http_method: 'GET', path: '/example', status: 200) }

  after do
    RSpec::OpenAPI.path_records.clear
    described_class.instance_variable_set(:@dump_scheduled, nil)
  end

  describe '.worker?' do
    it 'is false in the process that loaded the gem' do
      expect(described_class.worker?).to eq(false)
    end

    it 'is true when the pid differs from the loading process' do
      stub_const("#{described_class}::MAIN_PID", -1)
      expect(described_class.worker?).to eq(true)
    end
  end

  describe '.schedule_dump!' do
    it 'registers the dump only once per worker process' do
      stub_const("#{described_class}::MAIN_PID", -1)
      allow(described_class).to receive(:at_exit)
      described_class.schedule_dump!
      described_class.schedule_dump!
      expect(described_class).to have_received(:at_exit).once
    end

    it 'does nothing in the main process' do
      allow(described_class).to receive(:at_exit)
      described_class.schedule_dump!
      expect(described_class).not_to have_received(:at_exit)
    end
  end

  describe '.dump! and .merge!' do
    it 'round-trips records through the dump directory' do
      RSpec::OpenAPI.path_records['doc/openapi.yaml'] << record
      described_class.dump!
      RSpec::OpenAPI.path_records.clear

      described_class.merge!
      expect(RSpec::OpenAPI.path_records['doc/openapi.yaml']).to eq([record])
    end

    it 'dumps nothing when no records were collected' do
      described_class.dump!
      described_class.merge!
      expect(RSpec::OpenAPI.path_records).to be_empty
    end

    it 'rebuilds uploaded files, which cannot be serialized as-is' do
      require 'action_dispatch'
      upload = ActionDispatch::Http::UploadedFile.new(
        tempfile: StringIO.new('png bytes'), filename: 'test.png', type: 'image/png',
      )
      record = RSpec::OpenAPI::Record.new(
        http_method: 'POST', path: '/images/upload', status: 200,
        request_params: { 'image' => upload, 'images' => [upload] },
      )
      RSpec::OpenAPI.path_records['doc/openapi.yaml'] << record
      described_class.dump!
      RSpec::OpenAPI.path_records.clear

      described_class.merge!
      restored = RSpec::OpenAPI.path_records['doc/openapi.yaml'].first.request_params
      [restored['image'], restored['images'].first].each do |file|
        expect(file).to be_an(ActionDispatch::Http::UploadedFile)
        expect(file.original_filename).to eq('test.png')
        expect(file.content_type).to eq('image/png')
      end
    end

    # A builder's lookup is a Proc, which no serializer can carry. The worker
    # asks it about every key of the record and dumps the answers instead.
    def json_record(formats:)
      RSpec::OpenAPI::Record.new(
        http_method: 'GET', path: '/example', status: 200, path_params: {}, query_params: {},
        request_headers: [], response_headers: [], response_content_type: 'application/json',
        response_body: { 'id' => 1, 'created_at' => '2020-07-17T00:00:00Z' },
        formats: formats,
      )
    end

    def round_trip(record)
      RSpec::OpenAPI.path_records['doc/openapi.yaml'] << record
      described_class.dump!
      RSpec::OpenAPI.path_records.clear

      described_class.merge!
      RSpec::OpenAPI.path_records['doc/openapi.yaml'].first
    end

    it 'dumps the answers of a lookup Proc for the keys of the record' do
      record = json_record(formats: ->(key) { key.end_with?('_at') ? 'date-time' : nil })
      restored = round_trip(record)
      expect(restored.formats).to eq('id' => nil, 'created_at' => 'date-time')
      expect(RSpec::OpenAPI::SchemaBuilder.build(restored)).to eq(RSpec::OpenAPI::SchemaBuilder.build(record))
    end

    it 'raises an error the lookup raised in the worker when the record is built again' do
      restored = round_trip(json_record(formats: ->(key) { raise ArgumentError, "no format for #{key}" }))
      expect { RSpec::OpenAPI::SchemaBuilder.build(restored) }
        .to raise_error(described_class::LookupError, 'formats lookup raised ArgumentError: no format for id')
    end
  end
end
