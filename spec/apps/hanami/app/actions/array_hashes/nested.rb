# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class Nested < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "fields" => [
              {
                "id" => "country_code",
                "options" => [
                  {
                    "id" => "us",
                    "label" => "United States"
                  },
                  {
                    "id" => "ca",
                    "label" => "Canada"
                  }
                ]
              },
              {
                "id" => "region_id",
                "options" => [
                  {
                    "id" => 1,
                    "label" => "New York"
                  },
                  {
                    "id" => 2,
                    "label" => "California"
                  }
                ]
              }
            ]
          }.to_json
        end
      end
    end
  end
end
