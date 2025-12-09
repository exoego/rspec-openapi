# frozen_string_literal: true

module Dry
  module Monitor
    # @api public
    class Clock
      # @api private
      def initialize(unit: :millisecond)
        @unit = unit
      end

      # @api public
      def measure
        start = current
        result = yield
        [result, current - start]
      end

      # @api public
      def current
        Process.clock_gettime(Process::CLOCK_MONOTONIC, @unit)
      end
    end
  end
end
