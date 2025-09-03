# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::OpenAPI::SchemaFile do
  describe '#read' do
    let(:schema_content) do
      <<~YAML
        openapi: 3.0.0
        info:
          title: My API
          version: 1.0.0
        paths:
          /:
            get:
              summary: A test endpoint
              parameters:
                - name: date
                  in: query
                  schema:
                    type: string
                    date: 2020-01-02 # Unquoted date
                    time: 2025-06-10 01:47:28Z
      YAML
    end

    it 'deserializes unquoted dates as Date objects when Date is permitted' do
      schema_file = RSpec::OpenAPI::SchemaFile.new('nonexistant/schema.yaml')

      expect(File).to receive(:read).and_return(schema_content)
      expect(File).to receive(:exist?).and_return(true)

      data = nil
      expect do
        data = schema_file.send(:read)
      end.not_to raise_error(Psych::DisallowedClass)
      expect(data.dig(:paths, :/, :get, :parameters, 0, :schema, :date).to_s).to eq('2020-01-02')
      expect(data.dig(:paths, :/, :get, :parameters, 0, :schema, :time).to_s).to eq('2025-06-10 01:47:28 UTC')
    end
  end
end
