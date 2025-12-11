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
                },
                "form" => [
                  {
                    "value" => "John Doe",
                    "options" => [
                      {"label" => "John Doe", "value" => "john_doe"},
                      {"label" => "Jane Doe", "value" => "jane_doe"}
                    ]
                  },
                  {
                    "value" => [],
                    "options" => {
                      "endpoint" => "some/endpoint"
                    }
                  },
                  {
                    "value" => nil,
                    "options" => nil
                  },
                ]
              },
              {
                "id" => 2,
                "config" => {
                  "port" => "3000",
                  "host" => "example.com",
                  "ssl" => true
                },
                "form" => nil
              },
              {
                "id" => 3,
                "config" => {
                  "port" => "9010",
                  "host" => "foo.example.com",
                  "ssl" => true
                },
                "form" => [
                  {
                    "value" => false,
                  },
                  {
                    "value" => ['First', 'Second'],
                  },
                  {
                    "value" => 3,
                  },
                ]
              },
            ]
          }.to_json
        end
      end
    end
  end
end
