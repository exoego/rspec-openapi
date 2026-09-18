# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'components updater spec' do
  describe 'a $ref nested inline, with no top-level $ref anywhere in the document' do
    let(:base) do
      {
        paths: {
          '/rooms': {
            get: {
              responses: {
                '200': {
                  content: {
                    'application/json': {
                      schema: {
                        type: 'object',
                        properties: {
                          room: {
                            '$ref': '#/components/schemas/Room',
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        components: {
          schemas: {
            Room: {
              type: 'object',
              description: 'should be preserved',
              properties: {
                id: { type: 'integer' },
                stale_field: { type: 'string' },
              },
            },
          },
        },
      }
    end

    let(:fresh) do
      {
        paths: {
          '/rooms': {
            get: {
              responses: {
                '200': {
                  content: {
                    'application/json': {
                      schema: {
                        type: 'object',
                        properties: {
                          room: {
                            type: 'object',
                            properties: {
                              id: { type: 'integer' },
                              name: { type: 'string' },
                            },
                            required: ['id', 'name'],
                          },
                        },
                        required: ['room'],
                      },
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    it 'still refreshes the schema instead of dropping it' do
      RSpec::OpenAPI::ComponentsUpdater.update!(base, fresh)

      room = base[:components][:schemas][:Room]
      expect(room[:description]).to eq('should be preserved')
      expect(room[:properties]).to include(name: { type: 'string' })
      expect(room[:properties]).not_to have_key(:stale_field)
    end
  end

  describe 'no $ref anywhere in the document' do
    let(:base) do
      {
        paths: {
          '/ping': {
            get: {
              responses: {
                '200': {
                  content: {
                    'application/json': {
                      schema: {
                        type: 'object',
                        properties: {
                          ok: { type: 'boolean' },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        components: {
          schemas: {
            Unrelated: {
              type: 'object',
              properties: {
                id: { type: 'integer' },
              },
            },
          },
        },
      }
    end

    let(:fresh) do
      {
        paths: {
          '/ping': {
            get: {
              responses: {
                '200': {
                  content: {
                    'application/json': {
                      schema: {
                        type: 'object',
                        properties: {
                          ok: { type: 'boolean' },
                        },
                        required: ['ok'],
                      },
                    },
                  },
                },
              },
            },
          },
        },
      }
    end

    it 'leaves other, unrelated components alone rather than wiping them' do
      RSpec::OpenAPI::ComponentsUpdater.update!(base, fresh)

      expect(base[:components][:schemas]).to have_key(:Unrelated)
    end
  end
end
