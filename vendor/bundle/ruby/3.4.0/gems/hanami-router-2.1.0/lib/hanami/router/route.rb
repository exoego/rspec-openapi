# frozen_string_literal: true

require "hanami/router/redirect"
require "hanami/router/block"

module Hanami
  class Router
    # A route from the router
    #
    # @since 2.0.0
    # @api public
    class Route
      # @since 2.0.0
      # @api private
      ROUTE_CONSTRAINT_SEPARATOR = ", "
      private_constant :ROUTE_CONSTRAINT_SEPARATOR

      # Returns the route's HTTP method.
      #
      # @example
      #   route.http_method # => "GET"
      #
      # @return [String]
      #
      # @since 2.0.0
      # @api public
      attr_reader :http_method

      # Returns the route's path.
      #
      # @example
      #   route.path # => "/a/b/c"
      #
      # @return [String]
      #
      # @since 2.0.0
      # @api public
      attr_reader :path

      # Returns the route's Rack endpoint, as given to `to:` when the route was defined.
      #
      # @return [Object]
      #
      # @since 2.0.0
      # @api public
      attr_reader :to

      # Returns the route's unique name, as given to `as:` when the route was defined.
      #
      # @return [Object]
      #
      # @since 2.0.0
      # @api public
      attr_reader :as

      # Returns the route's contraints hash for its path variables.
      #
      # @return [Hash]
      #
      # @since 2.0.0
      # @api public
      attr_reader :constraints

      # @api private
      # @since 2.0.0
      def initialize(http_method:, path:, to:, as: nil, constraints: {}, blk: nil) # rubocop:disable Metrics/ParameterLists
        @http_method = http_method
        @path = path
        @to = to
        @as = as
        @constraints = constraints
        @blk = blk
        freeze
      end

      # Returns true if the route is for the HEAD HTTP method.
      #
      # @return [Boolean]
      #
      # @see #http_method
      #
      # @since 2.0.0
      # @api public
      def head?
        http_method == ::Rack::HEAD
      end

      # Returns true if the route has a name.
      #
      # @return [Boolean]
      #
      # @see #as
      #
      # @since 2.0.0
      # @api public
      def as?
        !as.nil?
      end

      # Returns true if the route has any constraints.
      #
      # @return [Boolean]
      #
      # @see #constraints
      #
      # @since 2.0.0
      # @api public
      def constraints?
        constraints.any?
      end

      # Returns a string containing a human-readable representation of the route's {#to} endpoint.
      #
      # @return [String]
      #
      # @since 2.0.0
      # @api public
      def inspect_to(value = to)
        case value
        when String
          value
        when Proc
          "(proc)"
        when Class
          value.name || "(class)"
        when Block
          "(block)"
        when Redirect
          "#{value.destination} (HTTP #{to.code})"
        else
          inspect_to(value.class)
        end
      end

      # Returns a string containing a human-readable representation of the route's {#constraints}.
      #
      # @return [String]
      #
      # @since 2.0.0
      # @api public
      def inspect_constraints
        @constraints.map do |key, value|
          "#{key}: #{value.inspect}"
        end.join(ROUTE_CONSTRAINT_SEPARATOR)
      end

      # Returns a string containing a human-readable representation of the route's name.
      #
      # @return [String]
      #
      # @see #as
      #
      # @since 2.0.0
      # @api public
      def inspect_as
        as ? as.inspect : Router::EMPTY_STRING
      end
    end
  end
end
