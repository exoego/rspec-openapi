# frozen_string_literal: true

require "hanami/router/segment"

module Hanami
  module Middleware
    # Trie node to register scopes with custom Rack middleware
    #
    # @api private
    # @since 2.0.0
    class Node
      # @api private
      # @since 2.0.0
      attr_reader :app

      # @api private
      # @since 2.0.0
      def initialize
        @app = nil
        @variable = nil
        @fixed = nil
      end

      # @api private
      # @since 2.0.0
      def freeze
        @variable.freeze
        @fixed.freeze
        super
      end

      # @api private
      # @since 2.0.0
      def put(segment)
        if variable?(segment)
          @variable ||= {}
          @variable[segment_for(segment)] ||= self.class.new
        else
          @fixed ||= {}
          @fixed[segment] ||= self.class.new
        end
      end

      # @api private
      # @since 2.0.0
      def get(segment) # rubocop:disable Metrics/PerceivedComplexity
        found = @fixed&.fetch(segment, nil)
        return found if found

        @variable&.each do |matcher, node|
          break if found

          captured = matcher.match(segment)
          found = node if captured
        end

        return found if found

        self if leaf?
      end

      # @api private
      # @since 2.0.0
      def app!(app)
        @app = app
      end

      # @api private
      # @since 2.0.0
      def app?
        !@app.nil?
      end

      # @api private
      # @since 2.0.0
      def leaf?
        @fixed.nil? && @variable.nil?
      end

      # @api private
      # @since 2.0.3
      def variable?(segment)
        Router::ROUTE_VARIABLE_MATCHER.match?(segment)
      end

      # @api private
      # @since 2.0.3
      def segment_for(segment)
        Router::Segment.fabricate(segment)
      end
    end
  end
end
