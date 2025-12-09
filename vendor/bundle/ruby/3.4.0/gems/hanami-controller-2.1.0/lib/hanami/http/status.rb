# frozen_string_literal: true

require "rack/utils"

module Hanami
  # @since 0.1.0
  # @api private
  module Http
    # An HTTP status
    #
    # @since 0.1.0
    # @api private
    class Status
      # A set of standard codes and messages for HTTP statuses
      #
      # @since 0.1.0
      # @api private
      ALL = ::Rack::Utils::HTTP_STATUS_CODES

      # Symbolic names for status codes
      #
      # @since 2.0.2
      # @api private
      SYMBOLS = ::Rack::Utils::SYMBOL_TO_STATUS_CODE

      # Return a status for the given code
      #
      # @param code [Integer, Symbol] a valid HTTP code
      #
      # @return [Array] a pair of code and message for an HTTP status
      #
      # @raise [Hanami::Action::UnknownHttpStatusError] if the given code
      #   cannot be associated to a known HTTP status
      #
      # @since 0.1.0
      # @api private
      #
      # @see https://guides.hanamirb.org/v2.0/actions/status-codes/
      #
      # @example Integer HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.for_code(401)
      #     # => [401, "Unauthorized"]
      #
      # @example Symbol HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.for_code(:unauthorized)
      #     # => [401, "Unauthorized"]
      #
      # @example Unknown HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.for_code(999)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      #
      #   Hanami::Http::Status.for_code(:foo)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      def self.for_code(code)
        case code
        when Integer
          ALL.assoc(code)
        when Symbol
          ALL.assoc(SYMBOLS[code])
        end or raise ::Hanami::Action::UnknownHttpStatusError.new(code)
      end

      # Return a status code for the given code
      #
      # @param code [Integer,Symbol] a valid HTTP code
      #
      # @return [Integer] a message for the given status code
      #
      # @raise [Hanami::Action::UnknownHttpStatusError] if the given code
      #   cannot be associated to a known HTTP status
      #
      # @see https://guides.hanamirb.org/v2.0/actions/status-codes/
      #
      # @since 2.0.2
      # @api private
      #
      # @example Integer HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.lookup(401)
      #     # => 401
      #
      # @example Symbol HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.lookup(:unauthorized)
      #     # => 401
      #
      # @example Unknown HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.lookup(999)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      #
      #   Hanami::Http::Status.lookup(:foo)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      def self.lookup(code)
        for_code(code)[0]
      end

      # Return a message for the given status code
      #
      # @param code [Integer,Symbol] a valid HTTP code
      #
      # @return [String] a message for the given status code
      #
      # @raise [Hanami::Action::UnknownHttpStatusError] if the given code
      #   cannot be associated to a known HTTP status
      #
      # @see https://guides.hanamirb.org/v2.0/actions/status-codes/
      #
      # @since 0.3.2
      # @api private
      #
      # @example Integer HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.message_for(401)
      #     # => "Unauthorized"
      #
      # @example Symbol HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.message_for(:unauthorized)
      #     # => "Unauthorized"
      #
      # @example Unknown HTTP Status
      #   require "hanami/http/status"
      #
      #   Hanami::Http::Status.message_for(999)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      #
      #   Hanami::Http::Status.message_for(:foo)
      #     # => raise Hanami::Action::UnknownHttpStatusError
      def self.message_for(code)
        for_code(code)[1]
      end
    end
  end
end
