# frozen_string_literal: true

module HanamiTest
  module Actions
    module Users
      class Show < UserAction
        format :json

        def handle(request, response)
          response.body = find_user(request.params[:id]).to_json
        end
      end
    end
  end
end
