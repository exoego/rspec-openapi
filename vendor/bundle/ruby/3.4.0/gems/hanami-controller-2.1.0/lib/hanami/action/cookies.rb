# frozen_string_literal: true

module Hanami
  class Action
    # Cookies API
    #
    # This module isn't included by default.
    #
    # @since 0.1.0
    #
    # @see Hanami::Action::Cookies#cookies
    module Cookies
      private

      # Finalize the response by flushing cookies into the response
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Action#finish
      def finish(req, res, *)
        res.cookies.finish
        super
      end
    end
  end
end
