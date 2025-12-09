# frozen_string_literal: true

module Hanami
  module Utils
    # Checks for blank
    #
    # @since 0.8.0
    # @api private
    class Blank
      # Matcher for blank strings
      #
      # @since 0.8.0
      # @api private
      STRING_MATCHER = /\A[[:space:]]*\z/

      # Checks if object is blank
      #
      # @example Basic Usage
      #   require 'hanami/utils/blank'
      #
      #   Hanami::Utils::Blank.blank?(Hanami::Utils::String.new('')) # => true
      #   Hanami::Utils::Blank.blank?('  ')                          # => true
      #   Hanami::Utils::Blank.blank?(nil)                           # => true
      #   Hanami::Utils::Blank.blank?(true)                          # => false
      #   Hanami::Utils::Blank.blank?(1)                             # => false
      #
      # @param object the argument
      #
      # @return [TrueClass,FalseClass] info, whether object is blank
      #
      # @since 0.8.0
      # @api private
      def self.blank?(object)
        case object
        when String, ::String
          STRING_MATCHER === object
        when ::Hash, ::Array
          object.empty?
        when TrueClass, Numeric
          false
        when FalseClass, NilClass
          true
        else
          object.respond_to?(:empty?) ? object.empty? : !object
        end
      end

      # Checks if object is filled
      #
      # @example Basic Usage
      #   require 'hanami/utils/blank'
      #
      #   Hanami::Utils::Blank.filled?(true)                          # => true
      #   Hanami::Utils::Blank.filled?(1)                             # => true
      #   Hanami::Utils::Blank.filled?(Hanami::Utils::String.new('')) # => false
      #   Hanami::Utils::Blank.filled?('  ')                          # => false
      #   Hanami::Utils::Blank.filled?(nil)                           # => false
      #
      # @param object the argument
      #
      # @return [TrueClass,FalseClass] whether the object is filled
      #
      # @since 1.0.0
      # @api private
      def self.filled?(object)
        !blank?(object)
      end
    end
  end
end
