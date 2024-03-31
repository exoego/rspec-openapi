# frozen_string_literal: true

module HanamiTest
  module Actions
    module Extensions
      class Index < HanamiTest::Action
        def handle(_request, response)
          response.body = { message: 'created' }.to_json
        end
      end
    end
  end
end
