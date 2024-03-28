# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class UserAction < HanamiTest::Action
        include UserRepository

        handle_exception RecordNotFound => :handle_not_fount_error

        before :authenticate

        private

        def handle_not_fount_error(_request, response, _exception)
          response.status = 404
          response.body = { message: 'not found' }.to_json
        end
      end
    end
  end
end
