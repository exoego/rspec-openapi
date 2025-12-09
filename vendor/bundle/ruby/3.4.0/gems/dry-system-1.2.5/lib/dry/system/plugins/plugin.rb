# frozen_string_literal: true

module Dry
  module System
    module Plugins
      # @api private
      class Plugin
        attr_reader :name

        attr_reader :mod

        attr_reader :block

        # @api private
        def initialize(name, mod, &block)
          @name = name
          @mod = mod
          @block = block
        end

        # @api private
        def apply_to(system, **options)
          system.extend(stateful? ? mod.new(**options) : mod)
          system.instance_eval(&block) if block
          system
        end

        # @api private
        def load_dependencies(dependencies = mod_dependencies, gem = nil)
          Array(dependencies).each do |dependency|
            if dependency.is_a?(Array) || dependency.is_a?(Hash)
              dependency.each { |value| load_dependencies(*Array(value).reverse) }
            elsif !Plugins.loaded_dependencies.include?(dependency.to_s)
              load_dependency(dependency, gem)
            end
          end
        end

        # @api private
        def load_dependency(dependency, gem)
          Kernel.require dependency
          Plugins.loaded_dependencies << dependency.to_s
        rescue LoadError => exception
          raise PluginDependencyMissing.new(name, exception.message, gem)
        end

        # @api private
        def stateful?
          mod < Module
        end

        # @api private
        def mod_dependencies
          return EMPTY_ARRAY unless mod.respond_to?(:dependencies)

          mod.dependencies.is_a?(Array) ? mod.dependencies : [mod.dependencies]
        end
      end
    end
  end
end
