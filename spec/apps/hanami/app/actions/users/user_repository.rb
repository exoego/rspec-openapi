# frozen_string_literal: true
module HanamiTest
  module Actions
    module Users
      module UserRepository
        class RecordNotFound < StandardError; end

        def find_user(id = nil)
          case id
          when '1', nil
            {
              name: 'John Doe',
              relations: {
                avatar: {
                  url: 'https://example.com/avatar.jpg',
                },
                pets: [
                  { name: 'doge', age: 8 },
                ],
              },
            }
          when '2'
            {
            }
          else
            raise RecordNotFound
          end
        end
      end
    end
  end
end
