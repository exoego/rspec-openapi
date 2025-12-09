# frozen_string_literal: true

require "set"

module Dry
  module Events
    # Event filter
    #
    # A filter cherry-picks probes payload of events.
    # Events not matching the predicates don't fire callbacks.
    #
    # @api private
    class Filter
      NO_MATCH = ::Object.new.freeze

      # @!attribute [r] events
      #   @return [Array] A list of lambdas checking payloads
      attr_reader :checks

      # Create a new filter
      #
      # @param [Hash] filter Source filter
      #
      # @api private
      def initialize(filter)
        @checks = build_checks(filter)
      end

      # Test event payload against the checks
      #
      # @param [Hash] payload Event payload
      #
      # @api private
      def call(payload = EMPTY_HASH)
        checks.all? { |check| check.(payload) }
      end

      # Recursively build checks
      #
      # @api private
      def build_checks(filter, checks = EMPTY_ARRAY, keys = EMPTY_ARRAY)
        if filter.is_a?(::Hash)
          filter.reduce(checks) do |cs, (key, value)|
            build_checks(value, cs, [*keys, key])
          end
        else
          [*checks, method(:compare).curry.(keys, predicate(filter))]
        end
      end

      # @api private
      def compare(path, predicate, payload)
        value = path.reduce(payload) do |acc, key|
          if acc.is_a?(::Hash) && acc.key?(key)
            acc[key]
          else
            break NO_MATCH
          end
        end

        predicate.(value)
      end

      # @api private
      def predicate(value)
        case value
        when ::Proc then value
        when ::Array then value.method(:include?)
        else value.method(:==)
        end
      end
    end
  end
end
