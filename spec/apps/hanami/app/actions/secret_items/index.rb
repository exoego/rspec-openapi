# frozen_string_literal: true

module HanamiTest
  module Actions
    module SecretItems
      class Index < HanamiTest::Action
        format :json

        def handle(_request, response)
          response.body = { items: ['secrets'] }.to_json
        end
      end
    end
  end
end
