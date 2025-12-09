# frozen_string_literal: true

module Dry
  module Transformer
    # Container to define transproc functions in, and access them via `[]` method
    # from the outside of the module
    #
    # @example
    #   module FooMethods
    #     extend Dry::Transformer::Registry
    #
    #     def self.foo(name, prefix)
    #       [prefix, '_', name].join
    #     end
    #   end
    #
    #   fn = FooMethods[:foo, 'baz']
    #   fn['qux'] # => 'qux_baz'
    #
    #   module BarMethods
    #     extend FooMethods
    #
    #     def self.bar(*args)
    #       foo(*args).upcase
    #     end
    #   end
    #
    #   fn = BarMethods[:foo, 'baz']
    #   fn['qux'] # => 'qux_baz'
    #
    #   fn = BarMethods[:bar, 'baz']
    #   fn['qux'] # => 'QUX_BAZ'
    #
    # @api public
    module Registry
      # Builds the transformation
      #
      # @param [Proc, Symbol] fn
      #   A proc, a name of the module's own function, or a name of imported
      #   procedure from another module
      # @param [Object, Array] args
      #   Args to be carried by the transproc
      #
      # @return [Dry::Transformer::Function]
      #
      # @alias :t
      #
      def [](fn, *args)
        fetched = fetch(fn)

        return Function.new(fetched, args: args, name: fn) unless already_wrapped?(fetched)

        args.empty? ? fetched : fetched.with(*args)
      end
      alias_method :t, :[]

      # Returns wether the registry contains such transformation by its key
      #
      # @param [Symbol] key
      #
      # @return [Boolean]
      #
      def contain?(key)
        respond_to?(key) || store.contain?(key)
      end

      # Register a new function
      #
      # @example
      #   store.register(:to_json, -> v { v.to_json })

      #   store.register(:to_json) { |v| v.to_json }
      #
      def register(name, fn = nil, &block)
        if contain?(name)
          raise FunctionAlreadyRegisteredError, "Function #{name} is already defined"
        end

        @store = store.register(name, fn, &block)
        self
      end

      # Imports either a method (converted to a proc) from another module, or
      # all methods from that module.
      #
      # If the external module is a registry, looks for its imports too.
      #
      # @overload import(source)
      #   Loads all methods from the source object
      #
      #   @param [Object] source
      #
      # @overload import(*names, **options)
      #   Loads selected methods from the source object
      #
      #   @param [Array<Symbol>] names
      #   @param [Hash] options
      #   @options options [Object] :from The source object
      #
      # @overload import(name, **options)
      #   Loads selected methods from the source object
      #
      #   @param [Symbol] name
      #   @param [Hash] options
      #   @options options [Object] :from The source object
      #   @options options [Object] :as The new name for the transformation
      #
      # @return [itself] self
      #
      # @alias :import
      #
      def import(*args)
        @store = store.import(*args)
        self
      end
      alias_method :uses, :import

      # The store of procedures imported from external modules
      #
      # @return [Dry::Transformer::Store]
      #
      def store
        @store ||= Store.new
      end

      # Gets the procedure for creating a transproc
      #
      # @param [#call, Symbol] fn
      #   Either the procedure, or the name of the method of the current module,
      #   or the registered key of imported procedure in a store.
      #
      # @return [#call]
      #
      def fetch(fn)
        return fn unless fn.instance_of? Symbol

        respond_to?(fn) ? method(fn) : store.fetch(fn)
      rescue StandardError
        raise FunctionNotFoundError.new(fn, self)
      end

      private

      # @api private
      def already_wrapped?(func)
        func.is_a?(Dry::Transformer::Function) || func.is_a?(Dry::Transformer::Composite)
      end
    end
  end
end
