# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class MixedTypesNested < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => [
              {
                "id" => 1,
                "config" => {
                  "port" => 8080,
                  "host" => "localhost"
                }
              },
              {
                "id" => 2,
                "config" => {
                  "port" => "3000",
                  "host" => "example.com",
                  "ssl" => true
                }
              }
            ]
          }.to_json
        end
      end
    end
  end
end
