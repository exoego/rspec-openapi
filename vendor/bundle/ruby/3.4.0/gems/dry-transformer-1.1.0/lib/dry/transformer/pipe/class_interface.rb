# frozen_string_literal: true

require "dry/transformer/pipe/dsl"

module Dry
  module Transformer
    class Pipe
      # @api public
      module ClassInterface
        # @api private
        attr_reader :dsl

        # Return a base Dry::Transformer class with the
        # container configured to the passed argument.
        #
        # @example
        #
        #   class MyTransformer < Dry::Transformer[Transproc]
        #   end
        #
        # @param [Transproc::Registry] container
        #   The container to resolve transprocs from
        #
        # @return [subclass of Dry::Transformer]
        #
        # @api public
        def [](container)
          klass = Class.new(self)
          klass.container(container)
          klass
        end

        # @api private
        def inherited(subclass)
          super

          subclass.container(@container) if defined?(@container)

          subclass.instance_variable_set("@dsl", dsl.dup) if dsl
        end

        # Get or set the container to resolve transprocs from.
        #
        # @example
        #
        #   # Setter
        #   Dry::Transformer.container(Transproc)
        #   # => Transproc
        #
        #   # Getter
        #   Dry::Transformer.container
        #   # => Transproc
        #
        # @param [Transproc::Registry] container
        #   The container to resolve transprocs from
        #
        # @return [Transproc::Registry]
        #
        # @api private
        def container(container = Undefined)
          if container.equal?(Undefined)
            @container ||= Module.new.extend(Dry::Transformer::Registry)
          else
            @container = container
          end
        end

        # @api public
        def import(*args)
          container.import(*args)
        end

        # @api public
        def define!(&block)
          @dsl ||= DSL.new(container)
          @dsl.instance_eval(&block)
          self
        end

        # @api public
        def new(*)
          super.tap do |transformer|
            transformer.instance_variable_set("@transproc", dsl.(transformer)) if dsl
          end
        end
        ruby2_keywords(:new) if respond_to?(:ruby2_keywords, true)

        # Get a transformation from the container,
        # without adding it to the transformation pipeline
        #
        # @example
        #
        #   class Stringify < Dry::Transformer
        #     map_values t(:to_string)
        #   end
        #
        #   Stringify.new.call(a: 1, b: 2)
        #   # => {a: '1', b: '2'}
        #
        # @param [Proc, Symbol] fn
        #   A proc, a name of the module's own function, or a name of imported
        #   procedure from another module
        # @param [Object, Array] args
        #   Args to be carried by the transproc
        #
        # @return [Transproc::Function]
        #
        # @api public
        def t(fn, *args)
          container[fn, *args]
        end
      end
    end
  end
end
