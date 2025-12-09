# frozen_string_literal: true

require "mustermann/rails"

module Hanami
  class Router
    # Route path
    #
    # @since 2.0.0
    # @api private
    class Segment
      # @since 2.0.0
      # @api private
      def self.fabricate(segment, **constraints)
        Mustermann.new(segment, type: :rails, version: "5.0", capture: constraints)
      end
    end
  end
end
