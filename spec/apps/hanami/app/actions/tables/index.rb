# frozen_string_literal: true

module HanamiTest
  module Actions
    module Tables
      class Index < TableAction
        def handle(request, response)
          response.headers['X-Cursor'] = 100

          if request.params[:show_columns]
            response.body = [find_table('42')].to_json
          else
            response.body = [find_table].to_json
          end
        end
      end
    end
  end
end
