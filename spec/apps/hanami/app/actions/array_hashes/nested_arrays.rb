# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NestedArrays < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => [
              {
                "id" => 1,
                "tags" => ["ruby", "rails"]
              },
              {
                "id" => 2,
                "tags" => ["python", "django"]
              },
              {
                "id" => 3,
                "tags" => ["javascript"]
              }
            ]
          }.to_json
        end
      end
    end
  end
end
