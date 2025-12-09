# frozen_string_literal: true

require "hanami/router/segment"

module Hanami
  class Router
    # Trie node
    #
    # @api private
    # @since 2.0.0
    class Node
      # @api private
      # @since 2.0.0
      attr_reader :to

      # @api private
      # @since 2.0.0
      def initialize
        @variable = nil
        @fixed = nil
        @to = nil
      end

      # @api private
      # @since 2.0.0
      def put(segment, constraints)
        if variable?(segment)
          @variable ||= {}
          @variable[segment_for(segment, constraints)] ||= self.class.new
        else
          @fixed ||= {}
          @fixed[segment] ||= self.class.new
        end
      end

      # @api private
      # @since 2.0.0
      #
      def get(segment) # rubocop:disable Metrics/PerceivedComplexity
        return unless @variable || @fixed

        found = nil
        captured = nil

        found = @fixed&.fetch(segment, nil)
        return [found, nil] if found

        @variable&.each do |matcher, node|
          break if found

          captured = matcher.match(segment)
          found = node if captured
        end

        [found, captured&.named_captures]
      end

      # @api private
      # @since 2.0.0
      def leaf?
        @to
      end

      # @api private
      # @since 2.0.0
      def leaf!(to)
        @to = to
      end

      private

      # @api private
      # @since 2.0.0
      def variable?(segment)
        Router::ROUTE_VARIABLE_MATCHER.match?(segment)
      end

      # @api private
      # @since 2.0.0
      def segment_for(segment, constraints)
        Segment.fabricate(segment, **constraints)
      end

      # @api private
      # @since 2.0.0
      def fixed?(matcher)
        matcher.names.empty?
      end
    end
  end
end
