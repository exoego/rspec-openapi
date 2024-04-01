# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Create < TableAction
        format :json

        def handle(request, response)
          if request.params[:name].blank? || request.params[:name] == 'some_invalid_name'
            response.status = 422
            response.body = { error: 'invalid name parameter' }.to_json
          else
            response.status = 201
            response.body = find_table.to_json
          end
        end
      end
    end
  end
end
