# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    # Default auto-registration implementation
    #
    # This is currently configured by default for every System::Container.
    # Auto-registrar objects are responsible for loading files from configured
    # auto-register paths and registering components automatically within the
    # container.
    #
    # @api private
    class AutoRegistrar
      attr_reader :container

      def initialize(container)
        @container = container
      end

      # @api private
      def finalize!
        container.component_dirs.each do |component_dir|
          call(component_dir) if component_dir.auto_register?
        end
      end

      # @api private
      def call(component_dir)
        component_dir.each_component do |component|
          next unless register_component?(component)

          container.register(component.key, memoize: component.memoize?) { component.instance }
        end
      end

      private

      def register_component?(component)
        !container.registered?(component.key) && component.auto_register?
      end
    end
  end
end
