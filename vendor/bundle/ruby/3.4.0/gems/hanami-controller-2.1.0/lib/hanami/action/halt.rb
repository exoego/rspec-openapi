# frozen_string_literal: true

require "hanami/http/status"

module Hanami
  class Action
    # @api private
    # @since 2.0.0
    module Halt
      # @api private
      # @since 2.0.0
      def self.call(status, body = nil)
        code, message = Http::Status.for_code(status)
        throw :halt, [code, body || message]
      end
    end
  end
end
