# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    module Config
      # A configured namespace for a component dir
      #
      # Namespaces consist of three elements:
      #
      # - The `path` within the component dir to which its namespace rules should apply.
      # - A `key`, which determines the leading part of the key used to register
      #   each component in the container.
      # - A `const`, which is the Ruby namespace expected to contain the class constants
      #   defined within each component's source file. This value is expected to be an
      #   "underscored" string, intended to be run through the configured inflector to be
      #   converted into a real constant (e.g. `"foo_bar/baz"` will become `FooBar::Baz`)
      #
      # Namespaces are added and configured for a component dir via {Namespaces#add}.
      #
      # @see Namespaces#add
      #
      # @api public
      class Namespace
        ROOT_PATH = nil

        include Dry::Equalizer(:path, :key, :const)

        # @api public
        attr_reader :path

        # @api public
        attr_reader :key

        # @api public
        attr_reader :const

        # Returns a namespace configured to serve as the default root namespace for a
        # component dir, ensuring that all code within the dir can be loaded, regardless
        # of any other explictly configured namespaces
        #
        # @return [Namespace] the root namespace
        #
        # @api private
        def self.default_root
          new(
            path: ROOT_PATH,
            key: nil,
            const: nil
          )
        end

        # @api private
        def initialize(path:, key:, const:)
          @path = path
          # Default keys (i.e. when the user does not explicitly provide one) for non-root
          # paths will include path separators, which we must convert into key separators
          @key = key && key == path ? key.gsub(PATH_SEPARATOR, KEY_SEPARATOR) : key
          @const = const
        end

        # @api public
        def root?
          path == ROOT_PATH
        end

        # @api public
        def path?
          !root?
        end
      end
    end
  end
end
