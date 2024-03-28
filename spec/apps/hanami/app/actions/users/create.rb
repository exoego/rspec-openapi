# frozen_string_literal: true

module HanamiTest
  module Actions
    module Users
      class Create < UserAction
        format :json

        def handle(_request, response)
          res = {
            name: params[:name],
            relations: {
              avatar: {
                url: params[:avatar_url] || 'https://example.com/avatar.png',
              },
              pets: params[:pets] || [],
            },
          }

          response.status = 201
          response.body = res.to_json
        end
      end
    end
  end
end
