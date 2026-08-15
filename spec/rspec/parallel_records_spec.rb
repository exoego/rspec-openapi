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
  end
end
