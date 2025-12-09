# frozen_string_literal: true

require "hanami/router/node"

module Hanami
  class Router
    # Trie data structure to store routes
    #
    # @api private
    # @since 2.0.0
    class Trie
      # @api private
      # @since 2.0.0
      attr_reader :root

      # @api private
      # @since 2.0.0
      def initialize
        @root = Node.new
      end

      # @api private
      # @since 2.0.0
      def add(path, to, constraints)
        node = @root
        for_each_segment(path) do |segment|
          node = node.put(segment, constraints)
        end

        node.leaf!(to)
      end

      # @api private
      # @since 2.0.0
      def find(path)
        node = @root
        params = {}

        for_each_segment(path) do |segment|
          break unless node

          child, captures = node.get(segment)
          params.merge!(captures) if captures

          node = child
        end

        return [node.to, params] if node&.leaf?

        nil
      end

      private

      # @api private
      # @since 2.0.0
      SEGMENT_SEPARATOR = /\//
      private_constant :SEGMENT_SEPARATOR

      # @api private
      # @since 2.0.0
      def for_each_segment(path, &blk)
        _, *segments = path.split(SEGMENT_SEPARATOR)
        segments.each(&blk)
      end
    end
  end
end
