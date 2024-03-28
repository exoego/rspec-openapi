# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Show < TableAction
        format :json

        def handle(request, response)
          response.body = find_table(request.params[:id]).to_json
        end
      end
    end
  end
end
