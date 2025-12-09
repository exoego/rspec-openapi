# frozen_string_literal: true

module Dry
  module Logger
    # @since 1.0.0
    # @api private
    class Clock
      # @since 1.0.0
      # @api private
      attr_reader :unit

      # @since 1.0.0
      # @api private
      def initialize(unit: :nanosecond)
        @unit = unit
      end

      # @since 1.0.0
      # @api private
      def now
        Time.now
      end

      # @since 1.0.0
      # @api private
      def now_utc
        now.getutc
      end

      # @since 1.0.0
      # @api private
      def measure
        start = current
        result = yield
        [result, current - start]
      end

      private

      # @since 1.0.0
      # @api private
      def current
        Process.clock_gettime(Process::CLOCK_MONOTONIC, unit)
      end
    end
  end
end
