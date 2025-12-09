# frozen_string_literal: true

module Dry
  module Transformer
    # Immutable collection of named procedures from external modules
    #
    # @api private
    #
    class Store
      # @!attribute [r] methods
      #
      # @return [Hash] The associated list of imported procedures
      #
      attr_reader :methods

      # @!scope class
      # @!name new(methods = {})
      # Creates an immutable store with a hash of procedures
      #
      # @param [Hash] methods
      #
      # @return [Dry::Transformer::Store]

      # @private
      def initialize(methods = {})
        @methods = methods.dup.freeze
        freeze
      end

      # Returns a procedure by its key in the collection
      #
      # @param [Symbol] key
      #
      # @return [Proc]
      #
      def fetch(key)
        methods.fetch(key)
      end

      # Returns wether the collection contains such procedure by its key
      #
      # @param [Symbol] key
      #
      # @return [Boolean]
      #
      def contain?(key)
        methods.key?(key)
      end

      # Register a new function
      #
      # @example
      #   store.register(:to_json, -> v { v.to_json })

      #   store.register(:to_json) { |v| v.to_json }
      #
      def register(name, fn = nil, &block)
        self.class.new(methods.merge(name => fn || block))
      end

      # Imports proc(s) to the collection from another module
      #
      # @private
      #
      def import(*args)
        first = args.first
        return import_all(first) if first.instance_of?(Module)

        opts   = args.pop
        source = opts.fetch(:from)
        rename = opts.fetch(:as) { first.to_sym }

        return import_methods(source, args) if args.count > 1

        import_method(source, first, rename)
      end

      protected

      # Creates new immutable collection from the current one,
      # updated with either the module's singleton method,
      # or the proc having been imported from another module.
      #
      # @param [Module] source
      # @param [Symbol] name
      # @param [Symbol] new_name
      #
      # @return [Dry::Transformer::Store]
      #
      def import_method(source, name, new_name = name)
        from = name.to_sym
        to   = new_name.to_sym

        fn = source.is_a?(Registry) ? source.fetch(from) : source.method(from)
        self.class.new(methods.merge(to => fn))
      end

      # Creates new immutable collection from the current one,
      # updated with either the module's singleton methods,
      # or the procs having been imported from another module.
      #
      # @param [Module] source
      # @param [Array<Symbol>] names
      #
      # @return [Dry::Transformer::Store]
      #
      def import_methods(source, names)
        names.inject(self) { |a, e| a.import_method(source, e) }
      end

      # Creates new immutable collection from the current one,
      # updated with all singleton methods and imported methods
      # from the other module
      #
      # @param [Module] source The module to import procedures from
      #
      # @return [Dry::Transformer::Store]
      #
      def import_all(source)
        names = source.public_methods - Registry.instance_methods - Module.methods
        names -= [:initialize] # for compatibility with Rubinius
        names += source.store.methods.keys if source.is_a? Registry

        import_methods(source, names)
      end
    end
  end
end
