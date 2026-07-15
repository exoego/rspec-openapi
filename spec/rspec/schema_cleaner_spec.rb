# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'schema cleaner spec' do
  describe 'cleanup_conflicting_security_parameters!' do
    let(:auth_parameter) do
      { name: 'Secret-Key', in: 'header', required: true, schema: { type: 'string' } }
    end

    let(:path_parameter) do
      { name: 'id', in: 'path', required: true, schema: { type: 'string' } }
    end

    def build_spec(security:, parameters:)
      {
        paths: {
          '/widgets/{id}': {
            get: {
              security: security,
              parameters: parameters,
              responses: { '200' => { description: 'ok' } },
            },
          },
        },
        components: {
          securitySchemes: {
            SecretApiKeyAuth: { type: 'apiKey', in: 'header', name: 'Secret-Key' },
          },
        },
      }
    end

    def operation(spec)
      spec.dig(:paths, :'/widgets/{id}', :get)
    end

    it 'leaves a public operation with parameters alone' do
      spec = build_spec(security: [], parameters: [path_parameter])

      expect { RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec) }.not_to raise_error
      expect(operation(spec)[:parameters]).to eq([path_parameter])
    end

    it 'leaves an operation without a security requirement alone' do
      spec = build_spec(security: nil, parameters: [auth_parameter])

      RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)

      expect(operation(spec)[:parameters]).to eq([auth_parameter])
    end

    it 'removes a parameter that duplicates the security scheme' do
      spec = build_spec(security: [{ SecretApiKeyAuth: [] }], parameters: [auth_parameter, path_parameter])

      RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)

      expect(operation(spec)[:parameters]).to eq([path_parameter])
    end

    it 'drops the parameters key once emptied' do
      spec = build_spec(security: [{ SecretApiKeyAuth: [] }], parameters: [auth_parameter])

      RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)

      expect(operation(spec)).not_to have_key(:parameters)
    end

    it 'keeps parameters of an operation secured by another scheme' do
      spec = build_spec(security: [{ OtherAuth: [] }], parameters: [auth_parameter])

      RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)

      expect(operation(spec)[:parameters]).to eq([auth_parameter])
    end
  end
end
