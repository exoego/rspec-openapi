# frozen_string_literal: true

module MyEngine
  module Actions
    module Eng
      class Example < MyEngine::Action
        def handle(_request, response)
          response.headers['Content-Type'] = 'text/plain'
          response.body = 'AN ENGINE TEST'
        end
      end
    end
  end
end
