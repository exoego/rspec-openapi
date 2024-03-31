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

        def handle_not_fount_error(_request, _response, _exception)
          halt 404, { message: 'not found' }.to_json
        end

        def authenticate(request, response)
          return unless request.get_header('AUTHORIZATION') != APIKEY

          response.format = :json
          halt 401, { message: 'Unauthorized' }.to_json
        end
      end
    end
  end
end
