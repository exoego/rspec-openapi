# frozen_string_literal: true

module HanamiTest
  module Actions
    module Sites
      class SiteAction < HanamiTest::Action
        include SiteRepository

        handle_exception RecordNotFound => :handle_not_fount_error

        private

        def handle_not_fount_error(_request, response, _exception)
          response.status = 404
          response.body = { message: 'not found' }.to_json
        end
      end
    end
  end
end
