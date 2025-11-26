# frozen_string_literal: true

module HanamiTest
  module Actions
    module ArrayHashes
      class EmptyArray < HanamiTest::Action
        def handle(request, response)
          response.format = :json

          response.body = {
            "items" => []
          }.to_json
        end
      end
    end
  end
end
