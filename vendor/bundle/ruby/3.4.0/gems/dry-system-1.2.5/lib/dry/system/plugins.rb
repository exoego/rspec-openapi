# frozen_string_literal: true

module Dry
  module System
    module Plugins
      # Register a plugin
      #
      # @param [Symbol] name The name of a plugin
      # @param [Class] plugin Plugin module
      #
      # @return [Plugins]
      #
      # @api public
      def self.register(name, plugin, &)
        registry[name] = Plugin.new(name, plugin, &)
      end

      # @api private
      def self.registry
        @registry ||= {}
      end

      # @api private
      def self.loaded_dependencies
        @loaded_dependencies ||= []
      end

      # Enables a plugin if not already enabled.
      # Raises error if plugin cannot be found in the plugin registry.
      #
      # @param [Symbol] name The plugin name
      # @param [Hash] options Plugin options
      #
      # @return [self]
      #
      # @api public
      def use(name, **options)
        return self if enabled_plugins.include?(name)

        raise PluginNotFoundError, name unless (plugin = Dry::System::Plugins.registry[name])

        plugin.load_dependencies
        plugin.apply_to(self, **options)

        enabled_plugins << name

        self
      end

      # @api private
      def inherited(klass)
        klass.instance_variable_set(:@enabled_plugins, enabled_plugins.dup)
        super
      end

      # @api private
      def enabled_plugins
        @enabled_plugins ||= []
      end

      register(:bootsnap, Plugins::Bootsnap)
      register(:logging, Plugins::Logging)
      register(:env, Plugins::Env)
      register(:notifications, Plugins::Notifications)
      register(:monitoring, Plugins::Monitoring)
      register(:dependency_graph, Plugins::DependencyGraph)
      register(:zeitwerk, Plugins::Zeitwerk)
    end
  end
end
