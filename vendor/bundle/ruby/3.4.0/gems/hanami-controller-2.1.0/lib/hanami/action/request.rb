# frozen_string_literal: true

require "rack/mime"
require "rack/request"
require "rack/utils"
require "securerandom"
require_relative "errors"

module Hanami
  class Action
    # The HTTP request for an action, given to {Action#handle}.
    #
    # Inherits from `Rack::Request`, providing compatibility with Rack functionality.
    #
    # @see http://www.rubydoc.info/gems/rack/Rack/Request
    #
    # @since 0.3.1
    class Request < ::Rack::Request
      # Returns the request's params.
      #
      # For an action with {Validatable} included, this will be a {Params} instance, otherwise a
      # {BaseParams}.
      #
      # @return [BaseParams,Params]
      #
      # @since 2.0.0
      # @api public
      attr_reader :params

      # @since 2.0.0
      # @api private
      def initialize(env:, params:, session_enabled: false)
        super(env)

        @params = params
        @session_enabled = session_enabled
      end

      # Returns the request's ID
      #
      # @return [String]
      #
      # @since 2.0.0
      # @api public
      def id
        # FIXME: make this number configurable and document the probabilities of clashes
        @id ||= @env[Action::REQUEST_ID] = SecureRandom.hex(Action::DEFAULT_ID_LENGTH)
      end

      # Returns true if the session is enabled for the request.
      #
      # @return [Boolean]
      #
      # @api public
      # @since 2.1.0
      def session_enabled?
        @session_enabled
      end

      # Returns the session for the request.
      #
      # @return [Hash] the session object
      #
      # @raise [MissingSessionError] if the session is not enabled
      #
      # @see #session_enabled?
      # @see Response#session
      #
      # @since 2.0.0
      # @api public
      def session
        unless session_enabled?
          raise Hanami::Action::MissingSessionError.new("Hanami::Action::Request#session")
        end

        super
      end

      # Returns the flash for the request.
      #
      # @return [Flash]
      #
      # @raise [MissingSessionError] if sessions are not enabled
      #
      # @see Response#flash
      #
      # @since 2.0.0
      # @api public
      def flash
        unless session_enabled?
          raise Hanami::Action::MissingSessionError.new("Hanami::Action::Request#flash")
        end

        @flash ||= Flash.new(session[Flash::KEY])
      end

      # @since 2.0.0
      # @api private
      def accept?(mime_type)
        !!::Rack::Utils.q_values(accept).find do |mime, _|
          ::Rack::Mime.match?(mime_type, mime)
        end
      end

      # @since 2.0.0
      # @api private
      def accept_header?
        accept != Action::DEFAULT_ACCEPT
      end

      # @since 0.1.0
      # @api private
      def accept
        @accept ||= @env[Action::HTTP_ACCEPT] || Action::DEFAULT_ACCEPT
      end
    end
  end
end
