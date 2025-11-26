# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class NonHashItems < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => ["string1", "string2", "string3"]
          }.to_json
        end
      end
    end
  end
end
