# frozen_string_literal: true

module HanamiTest
  module Actions
    module Images
      class Index < HanamiTest::Action
        format :json

        def handle(_request, response)
          list = [
            {
              name: 'file.png',
              tags: [], # Keep this empty to check empty array is accepted
            },
          ]

          response.body = list.to_json
        end
      end
    end
  end
end
