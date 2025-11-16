# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class Index < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {"users" => [
            {
              "label" => "Jane Doe",
              "value" => "jane_doe"
            },
            {
              "label" => nil,
              "value" => "unknown",
              "invited" => true
            }
          ]}.to_json
        end
      end
    end
  end
end
