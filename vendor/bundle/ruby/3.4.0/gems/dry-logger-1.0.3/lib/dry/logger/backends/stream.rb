# frozen_string_literal: true

require "logger"

require "dry/logger/constants"
require "dry/logger/backends/core"

module Dry
  module Logger
    module Backends
      class Stream < ::Logger
        include Core

        # @since 0.1.0
        # @api private
        attr_reader :stream

        # @since 0.1.0
        # @api private
        attr_reader :level

        # @since 0.1.0
        # @api private
        def initialize(stream:, formatter:, level: DEFAULT_LEVEL, progname: nil, log_if: nil)
          super(stream, progname: progname)

          @stream = stream
          @level = LEVELS[level]

          self.log_if = log_if
          self.formatter = formatter
        end

        # @since 1.0.0
        # @api public
        def inspect
          %(#<#{self.class} stream=#{stream} level=#{level} log_if=#{log_if}>)
        end
      end
    end
  end
end
