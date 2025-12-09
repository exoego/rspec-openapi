# frozen_string_literal: true

require "json"

require "dry/logger/constants"
require "dry/logger/formatters/structured"

module Dry
  module Logger
    module Formatters
      # JSON formatter.
      #
      # This formatter returns log entries in JSON format.
      #
      # @since 0.1.0
      # @api public
      class JSON < Structured
        # @since 0.1.0
        # @api private
        def format(entry)
          hash = format_values(entry).compact
          hash.update(hash.delete(:exception)) if entry.exception?
          ::JSON.dump(hash)
        end

        # @since 0.1.0
        # @api private
        def format_severity(value)
          value.upcase
        end

        # @since 0.1.0
        # @api private
        def format_exception(value)
          {
            exception: value.class,
            message: value.message,
            backtrace: value.backtrace || EMPTY_ARRAY
          }
        end

        # @since 0.1.0
        # @api private
        def format_time(value)
          value.getutc.iso8601
        end
      end
    end
  end
end
