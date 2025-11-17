# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NonNullable < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {"users" => [
            {
              "label" => "Jane Doe",
              "value" => "jane_doe"
            },
            {
              "label" => "John Doe",
              "value" => "john_doe",
            }
          ]}.to_json
        end
      end
    end
  end
end
