# frozen_string_literal: true

module Hanami
  class Router
    class MountedPath
      def initialize(prefix, app)
        @prefix = prefix
        @app = app
      end

      def endpoint_and_params(env)
        return [] unless (match = @prefix.peek_match(env[::Rack::PATH_INFO]))

        if @prefix.to_s == "/"
          env[::Rack::SCRIPT_NAME] = EMPTY_STRING
        else
          env[::Rack::SCRIPT_NAME] = env[::Rack::SCRIPT_NAME].to_s + @prefix.to_s
          env[::Rack::PATH_INFO] = env[::Rack::PATH_INFO].sub(@prefix.to_s, EMPTY_STRING)
          env[::Rack::PATH_INFO] = DEFAULT_PREFIX if env[::Rack::PATH_INFO] == EMPTY_STRING
        end

        [@app, match.named_captures]
      end
    end
  end
end
