# frozen_string_literal: true

module Hanami
  class Router
    class GlobbedPath
      def initialize(http_method, path, to)
        @http_method = http_method
        @path = path
        @to = to
      end

      def endpoint_and_params(env)
        return [] unless @http_method == env[::Rack::REQUEST_METHOD]

        if (match = @path.match(env[::Rack::PATH_INFO]))
          [@to, match.named_captures]
        else
          []
        end
      end
    end
  end
end
