# frozen_string_literal: true

module HanamiTest
  module Actions
    module Extensions
      class Create < HanamiTest::Action
        def handle(_request, response)
          response.body = [{ name: 'my-ext-1' }].to_json
        end
      end
    end
  end
end
