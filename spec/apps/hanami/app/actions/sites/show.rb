# frozen_string_literal: true

module HanamiTest
  module Actions
    module Sites
      class Show < SiteAction
        format :json

        def handle(request, response)
          response.body = find_site(request.params[:name]).to_json
        end
      end
    end
  end
end
