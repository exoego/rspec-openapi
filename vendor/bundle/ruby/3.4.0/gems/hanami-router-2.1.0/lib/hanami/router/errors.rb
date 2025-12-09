# frozen_string_literal: true

module Hanami
  class Router
    # Base class for all Hanami::Router errors.
    #
    # @since 0.5.0
    # @api public
    class Error < StandardError
    end

    # Error raised when no endpoint is specified for a route.
    #
    # Endpoints must be specified by `to:` or a block.
    #
    # @since 2.0.0
    # @api public
    class MissingEndpointError < Error
      # @since 2.0.0
      # @api private
      def initialize(path)
        super("missing endpoint for #{path.inspect}")
      end
    end

    # Error raised when a named route could not be found.
    #
    # @see Hanami::Router#path
    # @see Hanami::Router#url
    #
    # @since 2.0.0
    # @api public
    class MissingRouteError < Error
      # @since 2.0.0
      # @api private
      def initialize(name)
        super("No route could be found with name #{name.inspect}")
      end
    end

    # Error raised when variables given for route cannot be expanded into a full path.
    #
    # @see Hanami::Router#path
    # @see Hanami::Router#url
    #
    # @since 2.0.0
    # @api public
    class InvalidRouteExpansionError < Error
      # @since 2.0.0
      # @api private
      def initialize(name, message)
        super("No route could be generated for `#{name.inspect}': #{message}")
      end
    end

    # Error raised when an unknown HTTP status code is given.
    #
    # @see Hanami::Router#redirect
    #
    # @since 2.0.0
    # @api public
    class UnknownHTTPStatusCodeError < Error
      # @since 2.0.0
      # @api private
      def initialize(code)
        super("Unknown HTTP status code: #{code.inspect}")
      end
    end

    # Error raised when a recognized route is called but has no callable endpoint.
    #
    # @see Hanami::Router#recognize
    # @see Hanami::Router::RecognizedRoute#call
    #
    # @since 0.5.0
    # @api public
    class NotRoutableEndpointError < Error
      # @since 0.5.0
      # @api private
      def initialize(env)
        super(%(Cannot find routable endpoint for: #{env[::Rack::REQUEST_METHOD]} #{env[::Rack::PATH_INFO]}))
      end
    end
  end
end
