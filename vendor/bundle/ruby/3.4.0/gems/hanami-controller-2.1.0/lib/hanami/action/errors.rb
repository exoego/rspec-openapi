# frozen_string_literal: true

module Hanami
  class Action
    # Base class for all Action errors.
    #
    # @api public
    # @since 2.0.0
    class Error < ::StandardError
    end

    # Unknown status HTTP Status error
    #
    # @since 2.0.2
    #
    # @see Hanami::Action::Response#status=
    # @see https://guides.hanamirb.org/v2.0/actions/status-codes/
    class UnknownHttpStatusError < Error
      # @since 2.0.2
      # @api private
      def initialize(code)
        super("unknown HTTP status: `#{code.inspect}'")
      end
    end

    # Unknown format error
    #
    # This error is raised when a action sets a format that it isn't recognized
    # both by `Hanami::Action::Configuration` and the list of Rack mime types
    #
    # @since 2.0.0
    #
    # @see Hanami::Action::Mime#format=
    class UnknownFormatError < Error
      # @since 2.0.0
      # @api private
      def initialize(format)
        message = <<~MSG
          Cannot find a corresponding MIME type for format `#{format.inspect}'.
        MSG

        unless blank?(format)
          message += <<~MSG

            Configure one via: `config.actions.formats.add(:#{format}, "MIME_TYPE_HERE")' in `config/app.rb' to share between actions of a Hanami app.

            Or make it available only in the current action: `config.formats.add(:#{format}, "MIME_TYPE_HERE")'.
          MSG
        end

        super(message)
      end

      private

      def blank?(format)
        format.to_s.match(/\A[[:space:]]*\z/)
      end
    end

    # Error raised when session is accessed but not enabled.
    #
    # This error is raised when `session` or `flash` is accessed/set on request/response objects
    # in actions which do not include `Hanami::Action::Session`.
    #
    # @see Hanami::Action::Session
    # @see Hanami::Action::Request#session
    # @see Hanami::Action::Response#session
    # @see Hanami::Action::Response#flash
    #
    # @api public
    # @since 2.0.0
    class MissingSessionError < Error
      # @api private
      # @since 2.0.0
      def initialize(session_method)
        super(<<~TEXT)
          Sessions are not enabled. To use `#{session_method}`:

          Configure sessions in your Hanami app, e.g.

            module MyApp
              class App < Hanami::App
                # See Rack::Session::Cookie for options
                config.sessions = :cookie, {**cookie_session_options}
              end
            end

          Or include session support directly in your action class:

            include Hanami::Action::Session
        TEXT
      end
    end

    # Invalid CSRF Token
    #
    # @since 0.4.0
    class InvalidCSRFTokenError < Error
    end
  end
end
