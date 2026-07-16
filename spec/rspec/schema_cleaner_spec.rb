# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

RSpec.describe RSpec::OpenAPI::SchemaCleaner do
  describe '.cleanup_conflicting_security_parameters!' do
    let(:authorization_parameter) do
      {
        name: 'Authorization',
        in: 'header',
        required: true,
        schema: { type: 'string' },
      }
    end

    let(:security_schemes) do
      {
        'bearerAuth' => {
          type: 'http',
          scheme: 'bearer',
          in: 'header',
          name: 'Authorization',
        },
      }
    end

    it 'keeps parameters on operations that opt out of security with an empty array' do
      spec = {
        paths: {
          :'/widgets/{id}' => {
            get: {
              security: [],
              parameters: [authorization_parameter],
              responses: { '200' => { description: 'ok' } },
            },
          },
        },
        components: {
          securitySchemes: security_schemes,
        },
      }

      expect { described_class.cleanup_conflicting_security_parameters!(spec) }.not_to raise_error
      expect(spec.dig(:paths, :'/widgets/{id}', :get, :parameters)).to eq([authorization_parameter])
    end

    it 'removes parameters that duplicate the applied security scheme' do
      spec = {
        paths: {
          :'/widgets/{id}' => {
            get: {
              security: [{ 'bearerAuth' => [] }],
              parameters: [authorization_parameter],
              responses: { '200' => { description: 'ok' } },
            },
          },
        },
        components: {
          securitySchemes: security_schemes,
        },
      }

      described_class.cleanup_conflicting_security_parameters!(spec)

      expect(spec.dig(:paths, :'/widgets/{id}', :get)).not_to have_key(:parameters)
    end
  end
end
