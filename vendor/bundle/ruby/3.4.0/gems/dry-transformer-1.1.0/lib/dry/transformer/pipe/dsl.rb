# frozen_string_literal: true

require "dry/transformer/compiler"

module Dry
  module Transformer
    class Pipe
      # @api public
      class DSL
        # @api private
        attr_reader :container

        # @api private
        attr_reader :ast

        # @api private
        def initialize(container, ast: [], &block)
          @container = container
          @ast = ast
          instance_eval(&block) if block
        end

        # @api public
        def t(name, *args)
          container[name, *args]
        end

        # @api private
        def dup
          self.class.new(container, ast: ast.dup)
        end

        # @api private
        def call(transformer)
          Compiler.new(container, transformer).(ast)
        end

        private

        # @api private
        def node(&block)
          [:t, self.class.new(container, &block).ast]
        end

        # @api private
        def respond_to_missing?(method, _include_private = false)
          super || container.contain?(method)
        end

        # @api private
        def method_missing(meth, *args, &block)
          arg_nodes = *args.map { |a| [:arg, a] }
          ast << [:fn, (block ? [meth, [*arg_nodes, node(&block)]] : [meth, arg_nodes])]
        end
      end
    end
  end
end
