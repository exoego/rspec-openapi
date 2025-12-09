# frozen_string_literal: true

require "dry/system/constants"
require "dry/system/errors"

module Dry
  module System
    module Config
      # The configured component dirs for a container
      #
      # @api public
      class ComponentDirs
        # @!group Settings

        # @!method auto_register=(value)
        #
        #   Sets a default `auto_register` for all added component dirs
        #
        #   @see ComponentDir.auto_register=
        #   @see auto_register
        #
        # @!method auto_register
        #
        #   Returns the configured default `auto_register`
        #
        #   @see auto_register=

        # @!method instance=(value)
        #
        #   Sets a default `instance` for all added component dirs
        #
        #   @see ComponentDir.instance=
        #   @see auto_register
        #
        # @!method auto_register
        #
        #   Returns the configured default `instance`
        #
        #   @see instance=

        # @!method loader=(value)
        #
        #   Sets a default `loader` value for all added component dirs
        #
        #   @see ComponentDir.loader=
        #   @see loader
        #
        # @!method loader
        #
        #   Returns the configured default `loader`
        #
        #   @see loader=

        # @!method memoize=(value)
        #
        #   Sets a default `memoize` value for all added component dirs
        #
        #   @see ComponentDir.memoize=
        #   @see memoize
        #
        # @!method memoize
        #
        #   Returns the configured default `memoize`
        #
        #   @see memoize=

        # @!method namespaces
        #
        #   Returns the default configured namespaces for all added component dirs
        #
        #   Allows namespaces to added on the returned object via {Dry::System::Config::Namespaces#add}.
        #
        #   @see Dry::System::Config::Namespaces#add
        #
        #   @return [Namespaces] the namespaces

        # @!method add_to_load_path=(value)
        #
        #   Sets a default `add_to_load_path` value for all added component dirs
        #
        #   @see ComponentDir.add_to_load_path=
        #   @see add_to_load_path
        #
        # @!method add_to_load_path
        #
        #   Returns the configured default `add_to_load_path`
        #
        #   @see add_to_load_path=

        # @!endgroup

        # A ComponentDir for configuring the default values to apply to all added
        # component dirs
        #
        # @see #method_missing
        # @api private
        attr_reader :defaults

        # Creates a new component dirs
        #
        # @api private
        def initialize
          @dirs = {}
          @defaults = ComponentDir.new(nil)
        end

        # @api private
        def initialize_copy(source)
          @dirs = source.dirs.transform_values(&:dup)
          @defaults = source.defaults.dup
        end

        # Returns and optionally yields a previously added component dir
        #
        # @param path [String] the path for the component dir
        # @yieldparam dir [ComponentDir] the component dir
        #
        # @return [ComponentDir] the component dir
        #
        # @api public
        def dir(path)
          dirs[path].tap do |dir|
            # Defaults can be (re-)applied first, since the dir has already been added
            apply_defaults_to_dir(dir) if dir
            yield dir if block_given?
          end
        end
        alias_method :[], :dir

        # @overload add(path)
        #   Adds and configures a component dir for the given path
        #
        #   @param path [String] the path for the component dir, relative to the configured
        #     container root
        #   @yieldparam dir [ComponentDir] the component dir to configure
        #
        #   @return [ComponentDir] the added component dir
        #
        #   @example
        #     component_dirs.add "lib" do |dir|
        #       dir.default_namespace = "my_app"
        #     end
        #
        #   @see ComponentDir
        #   @api public
        #
        # @overload add(dir)
        #   Adds a configured component dir
        #
        #   @param dir [ComponentDir] the configured component dir
        #
        #   @return [ComponentDir] the added component dir
        #
        #   @example
        #     dir = Dry::System::ComponentDir.new("lib")
        #     component_dirs.add dir
        #
        #   @see ComponentDir
        #   @api public
        def add(path_or_dir)
          path, dir_to_add = path_and_dir(path_or_dir)

          raise ComponentDirAlreadyAddedError, path if dirs.key?(path)

          dirs[path] = dir_to_add.tap do |dir|
            # Defaults must be applied after yielding, since the dir is being newly added,
            # and must have its configuration fully in place before we can know which
            # defaults to apply
            yield dir if path_or_dir == path && block_given?
            apply_defaults_to_dir(dir)
          end
        end

        # Deletes and returns a previously added component dir
        #
        # @param path [String] the path for the component dir
        #
        # @return [ComponentDir] the removed component dir
        #
        # @api public
        def delete(path)
          dirs.delete(path)
        end

        # Returns the paths of the component dirs
        #
        # @return [Array<String>] the component dir paths
        #
        # @api public
        def paths
          dirs.keys
        end

        # Returns the count of component dirs
        #
        # @return [Integer]
        #
        # @api public
        def length
          dirs.length
        end
        alias_method :size, :length

        # Returns the added component dirs, with default settings applied
        #
        # @return [Array<ComponentDir>]
        #
        # @api public
        def to_a
          dirs.each { |_, dir| apply_defaults_to_dir(dir) }
          dirs.values
        end

        # Calls the given block once for each added component dir, passing the dir as an
        # argument.
        #
        # @yieldparam dir [ComponentDir] the yielded component dir
        #
        # @api public
        def each(&)
          to_a.each(&)
        end

        protected

        # Returns the hash of component dirs, keyed by their paths
        #
        # Recently changed default configuration may not be applied to these dirs. Use
        # #to_a or #each to access dirs with default configuration fully applied.
        #
        # This method exists to encapsulate the instance variable and to serve the needs
        # of #initialize_copy
        #
        # @return [Hash{String => ComponentDir}]
        #
        # @api private
        attr_reader :dirs

        private

        # Converts a path string or pre-built component dir into a path and dir tuple
        #
        # @param path_or_dir [String,ComponentDir]
        #
        # @return [Array<(String, ComponentDir)>]
        #
        # @see #add
        def path_and_dir(path_or_dir)
          if path_or_dir.is_a?(ComponentDir)
            dir = path_or_dir
            [dir.path, dir]
          else
            path = path_or_dir
            [path, ComponentDir.new(path)]
          end
        end

        # Applies default settings to a component dir. This is run every time the dirs are
        # accessed to ensure defaults are applied regardless of when new component dirs
        # are added. This method must be idempotent.
        #
        # @return [void]
        def apply_defaults_to_dir(dir)
          defaults.config.values.each do |key, _|
            if defaults.configured?(key) && !dir.configured?(key)
              dir.public_send(:"#{key}=", defaults.public_send(key).dup)
            end
          end
        end

        def method_missing(name, ...)
          if defaults.respond_to?(name)
            defaults.public_send(name, ...)
          else
            super
          end
        end

        def respond_to_missing?(name, include_all = false)
          defaults.respond_to?(name) || super
        end
      end
    end
  end
end
