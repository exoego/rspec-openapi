# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Index < TableAction
        def handle(request, response)
          response.headers['X-Cursor'] = 100

          response.format = :json

          response.body = if request.params[:show_columns]
                            [find_table('42')].to_json
                          else
                            [find_table].to_json
                          end
        end
      end
    end
  end
end
