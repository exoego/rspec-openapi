# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Update < TableAction
        def handle(request, response)
          response.body = find_table(request.params[:id]).to_json
        end
      end
    end
  end
end
