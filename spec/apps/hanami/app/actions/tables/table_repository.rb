# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      module TableRepository
        class RecordNotFound < StandardError; end

        def find_table(id = nil)
          time = Time.parse('2020-07-17 00:00:00')
          case id
          when '1', nil
            {
              id: 1,
              name: 'access',
              description: 'logs',
              database: {
                id: 2,
                name: 'production',
              },
              null_sample: nil,
              storage_size: 12.3,
              created_at: time.iso8601,
              updated_at: time.iso8601,
            }
          when '42'
            {
              id: 42,
              name: 'access',
              description: 'logs',
              database: {
                id: 4242,
                name: 'production',
              },
              columns: [
                { name: 'id', column_type: 'integer' },
                { name: 'description', column_type: 'varchar' },
              ],
              null_sample: nil,
              storage_size: 12.3,
              created_at: time.iso8601,
              updated_at: time.iso8601,
            }
          else
            raise RecordNotFound
          end
        end
      end
    end
  end
end
