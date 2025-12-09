# frozen_string_literal: true

require "dry/logger/constants"

module Dry
  module Logger
    module Backends
      module Core
        # Return a proc used by the log? predicate
        #
        # @since 1.0.0
        # @api private
        attr_reader :log_if

        # Set a predicate proc that checks if an entry should be logged by a given backend
        #
        # The predicate will receive {Entry} as its argument and should return true/false
        #
        # @param [Proc, #to_proc] spec A proc-like object
        # @since 1.0.0
        # @api public
        def log_if=(spec)
          @log_if = spec&.to_proc
        end

        # @since 1.0.0
        # @api private
        def log?(entry)
          if log_if
            log_if.call(entry)
          else
            true
          end
        end
      end
    end
  end
end
