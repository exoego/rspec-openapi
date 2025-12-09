# frozen_string_literal: true

require "hanami"

module Hanami
  module CLI
    module Commands
      module App
        # List registered middleware in the app router
        #
        # It outputs middleware registered along with the paths where they
        # apply:
        #
        # ```
        # $ bundle exec hanami middleware
        # /    Rack::Session::Cookie
        # ```
        #
        # Given arguments can be inspected:
        #
        # ```
        # $ bundle exec hanami middleware --with-arguments
        # /    Rack::Session::Cookie args: [{:secret=>"foo"}]
        # ```
        #
        # @since 2.0.0
        # @api private
        class Middleware < Hanami::CLI::Command
          desc "Print app Rack middleware stack"

          # @since 2.0.0
          # @api private
          DEFAULT_WITH_ARGUMENTS = false
          private_constant :DEFAULT_WITH_ARGUMENTS

          option :with_arguments, default: DEFAULT_WITH_ARGUMENTS, required: false,
                                  desc: "Include inspected arguments", type: :flag

          example [
            "middleware                  # Print app Rack middleware stack",
            "middleware --with-arguments # Print app Rack middleware stack, including initialize arguments",
          ]

          # @since 2.0.0
          # @api private
          def call(with_arguments: DEFAULT_WITH_ARGUMENTS)
            require "hanami/prepare"

            if Hanami.app.router
              inspector = MiddlewareStackInspector.new(stack: Hanami.app.router.middleware_stack)
              out.puts inspector.inspect(include_arguments: with_arguments)
            end
          end
        end
      end
    end
  end
end
