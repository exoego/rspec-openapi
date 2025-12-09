# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    module Config
      # @api public
      class ComponentDir
        include ::Dry::Configurable

        # @!group Settings

        # @!method auto_register=(policy)
        #
        #   Sets the auto-registration policy for the component dir.
        #
        #   This may be a simple boolean to enable or disable auto-registration for all
        #   components, or a proc accepting a {Dry::System::Component} and returning a
        #   boolean to configure auto-registration on a per-component basis
        #
        #   Defaults to `true`.
        #
        #   @param policy [Boolean, Proc]
        #   @return [Boolean, Proc]
        #
        #   @example
        #     dir.auto_register = false
        #
        #   @example
        #     dir.auto_register = proc do |component|
        #       !component.identifier.start_with?("entities")
        #     end
        #
        #   @see auto_register
        #   @see Component
        #   @api public
        #
        # @!method auto_register
        #
        #   Returns the configured auto-registration policy.
        #
        #   @return [Boolean, Proc] the configured policy
        #
        #   @see auto_register=
        #   @api public
        setting :auto_register, default: true

        # @!method instance=(instance_proc)
        #
        #   Sets a proc used to return the instance of any component within the component
        #   dir.
        #
        #   This proc should accept a {Dry::System::Component} and return the object to
        #   serve as the component's instance.
        #
        #   When you provide an instance proc, it will be used in preference to the
        #   {loader} (either the default loader or an explicitly configured one). Provide
        #   an instance proc when you want a simple way to customize the instance for
        #   certain components. For complete control, provide a replacement loader via
        #   {loader=}.
        #
        #   Defaults to `nil`.
        #
        #   @param instance_proc [Proc, nil]
        #   @return [Proc]
        #
        #   @example
        #     dir.instance = proc do |component|
        #       if component.key.match?(/workers\./)
        #         # Register classes for jobs
        #         component.loader.constant(component)
        #       else
        #         # Otherwise register regular instances per default loader
        #         component.loader.call(component)
        #       end
        #     end
        #
        #   @see Component, Loader
        #   @api public
        #
        # @!method instance
        #
        #   Returns the configured instance proc.
        #
        #   @return [Proc, nil]
        #
        #   @see instance=
        #   @api public
        setting :instance

        # @!method loader=(loader)
        #
        #   Sets the loader to use when registering components from the dir in the
        #   container.
        #
        #   Defaults to `Dry::System::Loader`.
        #
        #   When using an autoloader like Zeitwerk, consider using
        #   `Dry::System::Loader::Autoloading`
        #
        #   @param loader [#call] the loader
        #   @return [#call] the configured loader
        #
        #   @see loader
        #   @see Loader
        #   @see Loader::Autoloading
        #   @api public
        #
        # @!method loader
        #
        #   Returns the configured loader.
        #
        #   @return [#call]
        #
        #   @see loader=
        #   @api public
        setting :loader, default: Dry::System::Loader

        # @!method memoize=(policy)
        #
        #   Sets whether to memoize components from the dir when registered in the
        #   container.
        #
        #   This may be a simple boolean to enable or disable memoization for all
        #   components, or a proc accepting a `Dry::Sytem::Component` and returning a
        #   boolean to configure memoization on a per-component basis
        #
        #   Defaults to `false`.
        #
        #   @param policy [Boolean, Proc]
        #   @return [Boolean, Proc] the configured memoization policy
        #
        #   @example
        #     dir.memoize = true
        #
        #   @example
        #     dir.memoize = proc do |component|
        #       !component.identifier.start_with?("providers")
        #     end
        #
        #   @see memoize
        #   @see Component
        #   @api public
        #
        # @!method memoize
        #
        #   Returns the configured memoization policy.
        #
        #   @return [Boolean, Proc] the configured memoization policy
        #
        #   @see memoize=
        #   @api public
        setting :memoize, default: false

        # @!method namespaces
        #
        #   Returns the configured namespaces for the component dir.
        #
        #   Allows namespaces to added on the returned object via {Namespaces#add}.
        #
        #   @return [Namespaces] the namespaces
        #
        #   @see Namespaces#add
        #   @api public
        setting :namespaces, default: Namespaces.new, cloneable: true

        # @!method add_to_load_path=(policy)
        #
        #   Sets whether the dir should be added to the `$LOAD_PATH` after the container
        #   is configured.
        #
        #   Defaults to `true`. This may need to be set to `false` when using a class
        #   autoloading system.
        #
        #   @param policy [Boolean]
        #   @return [Boolean]
        #
        #   @see add_to_load_path
        #   @see Container.configure
        #   @api public
        #
        # @!method add_to_load_path
        #
        #   Returns the configured value.
        #
        #   @return [Boolean]
        #
        #   @see add_to_load_path=
        #   @api public
        setting :add_to_load_path, default: true

        # @!endgroup

        # Returns the component dir path, relative to the configured container root
        #
        # @return [String] the path
        attr_reader :path

        # @api public
        def initialize(path)
          super()
          @path = path
          yield self if block_given?
        end

        # @api private
        def auto_register?
          !!config.auto_register
        end

        private

        def method_missing(name, ...)
          if config.respond_to?(name)
            config.public_send(name, ...)
          else
            super
          end
        end

        def respond_to_missing?(name, include_all = false)
          config.respond_to?(name) || super
        end
      end
    end
  end
end
