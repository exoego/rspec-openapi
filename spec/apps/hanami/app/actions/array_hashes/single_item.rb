# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class SingleItem < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => [
              {
                "id" => 1,
                "name" => "Item 1"
              }
            ]
          }.to_json
        end
      end
    end
  end
end
