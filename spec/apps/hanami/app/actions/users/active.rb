# frozen_string_literal: true

module HanamiTest
  module Actions
    module Users
      class Active < UserAction
        format :json

        def handle(request, response)
          response.body = find_user(request.params[:id]).present?.to_json # present not exist in hanami
        end
      end
    end
  end
end
