# frozen_string_literal: true

require "logger"

require "dry/logger/constants"
require "dry/logger/filter"

module Dry
  module Logger
    module Formatters
      # Default structured formatter which receives {Logger::Entry} from the backends.
      #
      # This class can be used as the base class for your custom formatters.
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html
      #
      # @since 1.0.0
      # @api public
      class Structured < ::Logger::Formatter
        # @since 1.0.0
        # @api private
        DEFAULT_FILTERS = [].freeze

        # @since 1.0.0
        # @api private
        NOOP_FILTER = -> message { message }

        # @since 1.0.0
        # @api private
        attr_reader :filter

        # @since 1.0.0
        # @api private
        attr_reader :options

        # @since 1.0.0
        # @api private
        def initialize(filters: DEFAULT_FILTERS, **options)
          super()
          @filter = filters.equal?(DEFAULT_FILTERS) ? NOOP_FILTER : Filter.new(filters)
          @options = options
        end

        # Filter and then format the log entry into a string
        #
        # Custom formatters typically won't have to override this method because
        # the actual formatting logic is implemented as Structured#format
        #
        # @see http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/Logger/Formatter.html#method-i-call
        #
        # @since 1.0.0
        # @return [String]
        # @api public
        def call(_severity, _time, _progname, entry)
          format(entry.filter(filter)) + NEW_LINE
        end

        # Format entry into a loggable object
        #
        # Custom formatters should override this method
        #
        # @api since 1.0.0
        # @return [Entry]
        # @api public
        def format(entry)
          format_values(entry)
        end

        # @since 1.0.0
        # @api private
        def format_values(entry)
          entry
            .to_h
            .map { |key, value|
              [key, respond_to?(meth = "format_#{key}", true) ? __send__(meth, value) : value]
            }
            .to_h
        end
      end
    end
  end
end
