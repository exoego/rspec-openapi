# frozen_string_literal: true

module Dry
  module Transformer
    # Conditional transformation functions
    #
    # @example
    #   require 'dry/transformer/conditional'
    #
    #   include Dry::Transformer::Helper
    #
    #   fn = t(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })
    #
    #   [fn[2], fn['Jane']]
    #   # => [2, :Jane]
    #
    # @api public
    module Conditional
      extend Registry

      # Negates the result of transformation
      #
      # @example
      #   fn = Conditional[:not, -> value { value.is_a? ::String }]
      #   fn[:foo]  # => true
      #   fn["foo"] # => false
      #
      # @param [Object] value
      # @param [Proc] fn
      #
      # @return [Boolean]
      #
      # @api public
      def self.not(value, fn)
        !fn[value]
      end

      # Apply the transformation function to subject if the predicate returns true,
      # or return un-modified
      #
      # @example
      #   [2, 'Jane'].map do |subject|
      #     Dry::Transformer(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })[subject]
      #   end
      #   # => [2, :Jane]
      #
      # @param [Mixed]
      #
      # @return [Mixed]
      #
      # @api public
      def self.guard(value, predicate, fn)
        predicate[value] ? fn[value] : value
      end

      # Calls a function when type-check passes
      #
      # @example
      #   fn = Dry::Transformer(:is, Array, -> arr { arr.map(&:upcase) })
      #   fn.call(['a', 'b', 'c']) # => ['A', 'B', 'C']
      #
      #   fn = Dry::Transformer(:is, Array, -> arr { arr.map(&:upcase) })
      #   fn.call('foo') # => "foo"
      #
      # @param [Object]
      # @param [Class]
      # @param [Proc]
      #
      # @return [Object]
      #
      # @api public
      def self.is(value, type, fn)
        guard(value, -> v { v.is_a?(type) }, fn)
      end
    end
  end
end
