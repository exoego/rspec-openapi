# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NestedObjects < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => [
              {
                "id" => 1,
                "metadata" => {
                  "author" => "Alice",
                  "version" => "1.0"
                }
              },
              {
                "id" => 2,
                "metadata" => {
                  "author" => "Bob",
                  "version" => "2.0",
                  "reviewed" => true
                }
              },
              {
                "id" => 3,
                "metadata" => {
                  "author" => "Charlie"
                }
              }
            ]
          }.to_json
        end
      end
    end
  end
end
