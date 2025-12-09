# frozen_string_literal: true

module Dry
  module Transformer
    # @api private
    class Compiler
      InvalidFunctionNameError = Class.new(StandardError)

      attr_reader :registry, :transformer

      def initialize(registry, transformer = nil)
        @registry = registry
        @transformer = transformer
      end

      def call(ast)
        ast.map(&method(:visit)).reduce(:>>)
      end

      def visit(node)
        id, *rest = node
        public_send(:"visit_#{id}", *rest)
      end

      def visit_fn(node)
        name, rest = node
        args = rest.map { |arg| visit(arg) }

        if registry.contain?(name)
          registry[name, *args]
        elsif transformer.respond_to?(name)
          Function.new(transformer.method(name), name: name, args: args)
        else
          raise InvalidFunctionNameError, "function name +#{name}+ is not valid"
        end
      end

      def visit_arg(arg)
        arg
      end

      def visit_t(node)
        call(node)
      end
    end
  end
end
