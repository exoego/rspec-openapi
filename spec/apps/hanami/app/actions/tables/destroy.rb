# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Destroy < TableAction
        def handle(request, response)
          response.format = :json
          if request.params[:no_content]
            response.status = 202
          else
            response.body = find_table(request.params[:id]).to_json
          end
        end
      end
    end
  end
end
