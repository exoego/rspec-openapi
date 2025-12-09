# frozen_string_literal: true

require "hanami/router/formatter/human_friendly"

module Hanami
  class Router
    # Builds a representation of an array of routes according to a given formatter.
    #
    # @see Router.new
    #
    # @since 2.0.0
    # @api private
    class Inspector
      # @param routes [Array<Hanami::Route>]
      # @param formatter [#call] routes formatter, taking routes as an argument and returning its
      #   own representation (typically a string). Defaults to {Formatter::HumanFriendly}.
      #
      # @since 2.0.0
      # @api public
      def initialize(routes: [], formatter: Formatter::HumanFriendly.new)
        @routes = routes
        @formatter = formatter
      end

      # Adds a route to be inspected.
      #
      # @param route [Route]
      #
      # @since 2.0.0
      # @api public
      def add_route(route)
        @routes.push(route)
      end

      # Calls the formatter for all added routes.
      #
      # @return [Any] Formatted routes
      #
      # @since 2.0.0
      # @api public
      def call(...)
        @formatter.call(@routes, ...)
      end
    end
  end
end
