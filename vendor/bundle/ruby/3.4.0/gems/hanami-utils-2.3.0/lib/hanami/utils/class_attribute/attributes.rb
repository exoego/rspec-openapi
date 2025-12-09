# frozen_string_literal: true

require "concurrent/map"

module Hanami
  module Utils
    module ClassAttribute
      # Class attributes set
      #
      # @since 2.0.0
      # @api private
      class Attributes
        # @since 2.0.0
        # @api private
        def initialize(attributes: Concurrent::Map.new)
          @attributes = attributes
        end

        # @since 2.0.0
        # @api private
        def []=(key, value)
          @attributes[key.to_sym] = value
        end

        # @since 2.0.0
        # @api private
        def [](key)
          @attributes.fetch(key, nil)
        end

        # @since 2.0.0
        # @api private
        def dup
          attributes = Concurrent::Map.new.tap do |attrs|
            @attributes.each do |key, value|
              attrs[key.to_sym] = value.dup
            end
          end

          self.class.new(attributes: attributes)
        end
      end
    end
  end
end
