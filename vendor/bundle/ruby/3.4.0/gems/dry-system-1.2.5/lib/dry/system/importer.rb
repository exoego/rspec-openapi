# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    # Default importer implementation
    #
    # This is currently configured by default for every System::Container.
    # Importer objects are responsible for importing components from one
    # container to another. This is used in cases where an application is split
    # into multiple sub-systems.
    #
    # @api private
    class Importer
      # @api private
      class Item
        attr_reader :namespace, :container, :import_keys

        def initialize(namespace:, container:, import_keys:)
          @namespace = namespace
          @container = container
          @import_keys = import_keys
        end
      end

      attr_reader :container

      attr_reader :registry

      # @api private
      def initialize(container)
        @container = container
        @registry = {}
      end

      # @api private
      def register(namespace:, container:, keys: nil)
        registry[namespace_key(namespace)] = Item.new(
          namespace: namespace,
          container: container,
          import_keys: keys
        )
      end

      # @api private
      def [](name)
        registry.fetch(namespace_key(name))
      end

      # @api private
      def key?(name)
        registry.key?(namespace_key(name))
      end
      alias_method :namespace?, :key?

      # @api private
      def finalize!
        registry.each_key { import(_1) }
        self
      end

      # @api private
      def import(namespace, keys: Undefined)
        item = self[namespace]
        keys = Undefined.default(keys, item.import_keys)

        if keys
          import_keys(item.container, namespace, keys_to_import(keys, item))
        else
          import_all(item.container, namespace)
        end

        self
      end

      private

      # Returns nil if given a nil (i.e. root) namespace. Otherwise, converts the namespace to a
      # string.
      #
      # This ensures imported components are found when either symbols or strings to given as the
      # namespace in {Container.import}.
      def namespace_key(namespace)
        return nil if namespace.nil?

        namespace.to_s
      end

      def keys_to_import(keys, item)
        keys
          .then { (arr = item.import_keys) ? _1 & arr : _1 }
          .then { (arr = item.container.exports) ? _1 & arr : _1 }
      end

      def import_keys(other, namespace, keys)
        merge(container, build_merge_container(other, keys), namespace: namespace)
      end

      def import_all(other, namespace)
        merge_container =
          if other.exports
            build_merge_container(other, other.exports)
          else
            build_merge_container(other.finalize!, other.keys)
          end

        merge(container, merge_container, namespace: namespace)
      end

      # Merges `other` into `container`, favoring the container's existing registrations
      def merge(container, other, namespace:)
        container.merge(other, namespace: namespace) { |_key, old_item, new_item|
          old_item || new_item
        }
      end

      def build_merge_container(other, keys)
        keys.each_with_object(Core::Container.new) { |key, ic|
          next unless other.key?(key)

          # Access the other container's items directly so that we can preserve all their
          # options when we merge them with the target container (e.g. if a component in
          # the provider container was registered with a block, we want block registration
          # behavior to be exhibited when later resolving that component from the target
          # container). TODO: Make this part of dry-system's public API.
          item = other._container[key]

          # By default, we "protect" components that were themselves imported into the
          # other container from being implicitly exported; imported components are
          # considered "private" and must be explicitly included in `exports` to be
          # exported.
          next if item.options[:imported] && !other.exports

          if item.callable?
            ic.register(key, **item.options, imported: true, &item.item)
          else
            ic.register(key, item.item, **item.options, imported: true)
          end
        }
      end
    end
  end
end
