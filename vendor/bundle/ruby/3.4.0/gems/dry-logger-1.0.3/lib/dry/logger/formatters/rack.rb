# frozen_string_literal: true

require "dry/logger/formatters/structured"

module Dry
  module Logger
    module Formatters
      # Special handling of `:params` in the log entry payload
      #
      # @since 1.0.0
      # @api private
      #
      # @see String
      class Rack < String
        # @see String#initialize
        # @since 1.0.0
        # @api private
        def initialize(**options)
          super
          @template = Template[Logger.templates[:rack]]
        end

        # @api 1.0.0
        # @api private
        def format_params(value)
          return value unless value.empty?
        end
      end
    end
  end
end
