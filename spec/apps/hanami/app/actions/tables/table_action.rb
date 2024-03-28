# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class TableAction < HanamiTest::Action
        APIKEY = 'k0kubun'.freeze

        include TableRepository

        handle_exception RecordNotFound => :handle_not_fount_error

        before :authenticate

        private

        def handle_not_fount_error(_request, response, _exception)
          response.status = 404
          response.body = { message: 'not found' }.to_json
        end

        def authenticate(request, _response)
          if request.get_header('authorization') != APIKEY
            halt 401, { message: 'Unauthorized' }.to_json
          end
        end
      end
    end
  end
end
