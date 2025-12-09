# frozen_string_literal: true

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    class MiddlewareStackInspector
      # @since 2.0.0
      # @api private
      def initialize(stack:)
        @stack = stack
      end

      # @since 2.0.0
      # @api private
      def inspect(include_arguments: false)
        max_path_length = @stack.map { |(path)| path.length }.max

        @stack.map { |path, middleware|
          middleware.map { |(mware, arguments)|
            "#{path.ljust(max_path_length + 3)} #{format_middleware(mware)}".tap { |line|
              line << " #{format_arguments(arguments)}" if include_arguments
            }
          }
        }.join("\n") + "\n"
      end

      private

      def format_middleware(middleware)
        case middleware
        when Class
          middleware.name || "(class)"
        when Module
          middleware.name || "(module)"
        else
          "#{middleware.class.name} (instance)"
        end
      end

      def format_arguments(arguments)
        "args: #{arguments.inspect}"
      end
    end
  end
end
