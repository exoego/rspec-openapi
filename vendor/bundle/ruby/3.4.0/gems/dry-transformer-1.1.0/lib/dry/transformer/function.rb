# frozen_string_literal: true

module Dry
  module Transformer
    # Transformation proc wrapper allowing composition of multiple procs into
    # a data-transformation pipeline.
    #
    # This is used by Dry::Transformer to wrap registered methods.
    #
    # @api private
    class Function
      # Wrapped proc or another composite function
      #
      # @return [Proc,Composed]
      #
      # @api private
      attr_reader :fn

      # Additional arguments that will be passed to the wrapped proc
      #
      # @return [Array]
      #
      # @api private
      attr_reader :args

      # @!attribute [r] name
      #
      # @return [<type] The name of the function
      #
      # @api public
      attr_reader :name

      # @api private
      def initialize(fn, options = {})
        @fn = fn
        @args = options.fetch(:args, [])
        @name = options.fetch(:name, fn)
      end

      # Call the wrapped proc
      #
      # @param [Object] value The input value
      #
      # @alias []
      #
      # @api public
      def call(*value)
        fn.call(*value, *args)
      end
      alias_method :[], :call

      # Compose this function with another function or a proc
      #
      # @param [Proc,Function]
      #
      # @return [Composite]
      #
      # @alias :>>
      #
      # @api public
      def compose(other)
        Composite.new(self, other)
      end
      alias_method :+, :compose
      alias_method :>>, :compose

      # Return a new fn with curried args
      #
      # @return [Function]
      #
      # @api private
      def with(*args)
        self.class.new(fn, name: name, args: args)
      end

      # @api public
      def ==(other)
        return false unless other.instance_of?(self.class)

        [fn, name, args] == [other.fn, other.name, other.args]
      end
      alias_method :eql?, :==

      # Return a simple AST representation of this function
      #
      # @return [Array]
      #
      # @api public
      def to_ast
        args_ast = args.map { |arg| arg.respond_to?(:to_ast) ? arg.to_ast : arg }
        [name, args_ast]
      end

      # Converts a transproc to a simple proc
      #
      # @return [Proc]
      #
      def to_proc
        if !args.empty?
          proc { |*value| fn.call(*value, *args) }
        else
          fn.to_proc
        end
      end
    end
  end
end
