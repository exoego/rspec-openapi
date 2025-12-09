# frozen_string_literal: true

module Hanami
  class Action
    # Session support for actions.
    #
    # Not included by default; you should include this module manually to enable session support.
    # For actions within an Hanami app, this module will be included automatically if sessions are
    # configured in the app config.
    #
    # @api public
    # @since 0.1.0
    module Session
      # @api private
      # @since 0.1.0
      def self.included(base)
        base.class_eval do
          before { |req, _| req.id }
        end
      end

      private

      def session_enabled?
        true
      end

      # Finalize the response
      #
      # @return [void]
      #
      # @since 0.3.0
      # @api private
      #
      # @see Hanami::Action#finish
      def finish(req, res, *)
        if (next_flash = res.flash.next).any?
          res.session[Flash::KEY] = next_flash
        else
          res.session.delete(Flash::KEY)
        end

        super
      end
    end
  end
end
