# frozen_string_literal: true

module Hanami
  class Router
    # Represents a result of router path recognition.
    #
    # @see Hanami::Router#recognize
    #
    # @since 0.5.0
    # @api public
    class RecognizedRoute
      # @since 0.5.0
      # @api private
      def initialize(endpoint, env)
        @endpoint = endpoint
        @env = env
      end

      # Rack protocol compatibility
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] serialized Rack response
      #
      # @raise [Hanami::Router::NotRoutableEndpointError] if not routable
      #
      # @since 0.5.0
      # @api public
      #
      # @see Hanami::Router::RecognizedRoute#routable?
      # @see Hanami::Router::NotRoutableEndpointError
      def call(env)
        if routable?
          @endpoint.call(env)
        else
          raise NotRoutableEndpointError.new(@env)
        end
      end

      # HTTP verb (aka method)
      #
      # @return [String]
      #
      # @since 0.5.0
      # @api public
      def verb
        @env[::Rack::REQUEST_METHOD]
      end

      # Relative URL (path)
      #
      # @return [String]
      #
      # @since 0.7.0
      # @api public
      def path
        @env[::Rack::PATH_INFO]
      end

      # Returns the route's path params.
      #
      # @return [Hash]
      #
      # @since 0.7.0
      # @api public
      def params
        @env[Router::PARAMS]
      end

      # Returns the route's endpoint object.
      #
      # Returns nil if the route is a {#redirect? redirect}.
      #
      # @return [Object, nil]
      #
      # @since 0.7.0
      # @api public
      def endpoint
        return nil if redirect?

        @endpoint
      end

      # Returns true if the route has an {#endpoint}.
      #
      # @return [Boolean]
      #
      # @since 0.7.0
      # @api public
      def routable?
        !@endpoint.nil?
      end

      # Returns true if the route is a redirect.
      #
      # @return [Boolean]
      #
      # @since 0.7.0
      # @api public
      def redirect?
        @endpoint.is_a?(Redirect)
      end

      # Returns the route's redirect path, if it is a redirect, or nil otherwise.
      #
      # @return [String, nil]
      #
      # @since 0.7.0
      # @api public
      def redirection_path
        return nil unless redirect?

        @endpoint.destination
      end
    end
  end
end
