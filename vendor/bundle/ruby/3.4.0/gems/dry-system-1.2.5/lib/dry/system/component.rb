# frozen_string_literal: true

require "pathname"
require "dry/inflector"
require "dry/system/errors"
require "dry/system/constants"

module Dry
  module System
    # Components are objects providing information about auto-registered files.
    # They expose an API to query this information and use a configurable
    # loader object to initialize class instances.
    #
    # @api public
    class Component
      include Dry::Equalizer(:identifier, :file_path, :namespace, :options)

      DEFAULT_OPTIONS = {
        inflector: Dry::Inflector.new,
        loader: Loader
      }.freeze

      # @!attribute [r] identifier
      #   @return [String] the component's unique identifier
      attr_reader :identifier

      # @!attribute [r] file_path
      #   @return [Pathname] the component's source file path
      attr_reader :file_path

      # @!attribute [r] namespace
      #   @return [Dry::System::Config::Namespace] the component's namespace
      attr_reader :namespace

      # @!attribute [r] options
      #   @return [Hash] the component's options
      attr_reader :options

      # @api private
      def initialize(identifier, file_path:, namespace:, **options)
        @identifier = identifier
        @file_path = Pathname(file_path)
        @namespace = namespace
        @options = DEFAULT_OPTIONS.merge(options)
      end

      # Returns true, indicating that the component is directly loadable from the files
      # managed by the container
      #
      # This is the inverse of {IndirectComponent#loadable?}
      #
      # @return [TrueClass]
      #
      # @api private
      def loadable?
        true
      end

      # Returns the component's instance
      #
      # @return [Object] component's class instance
      # @api public
      def instance(*args, **kwargs)
        options[:instance]&.call(self, *args, **kwargs) || loader.call(self, *args, **kwargs)
      end

      # Returns the component's unique key
      #
      # @return [String] the key
      #
      # @see Identifier#key
      #
      # @api public
      def key
        identifier.key
      end

      # Returns the root namespace segment of the component's key, as a symbol
      #
      # @see Identifier#root_key
      #
      # @return [Symbol] the root key
      #
      # @api public
      def root_key
        identifier.root_key
      end

      # Returns a path-delimited representation of the compnent, appropriate for passing
      # to `Kernel#require` to require its source file
      #
      # The path takes into account the rules of the namespace used to load the component.
      #
      # @example Component from a root namespace
      #   component.key # => "articles.create"
      #   component.require_path # => "articles/create"
      #
      # @example Component from an "admin/" path namespace (with `key: nil`)
      #   component.key # => "articles.create"
      #   component.require_path # => "admin/articles/create"
      #
      # @see Config::Namespaces#add
      # @see Config::Namespace
      #
      # @return [String] the require path
      #
      # @api public
      def require_path
        if namespace.path
          "#{namespace.path}#{PATH_SEPARATOR}#{path_in_namespace}"
        else
          path_in_namespace
        end
      end

      # Returns an "underscored", path-delimited representation of the component,
      # appropriate for passing to the inflector for constantizing
      #
      # The const path takes into account the rules of the namespace used to load the
      # component.
      #
      # @example Component from a namespace with `const: nil`
      #   component.key # => "articles.create_article"
      #   component.const_path # => "articles/create_article"
      #   component.inflector.constantize(component.const_path) # => Articles::CreateArticle
      #
      # @example Component from a namespace with `const: "admin"`
      #   component.key # => "articles.create_article"
      #   component.const_path # => "admin/articles/create_article"
      #   component.inflector.constantize(component.const_path) # => Admin::Articles::CreateArticle
      #
      # @see Config::Namespaces#add
      # @see Config::Namespace
      #
      # @return [String] the const path
      #
      # @api public
      def const_path
        namespace_const_path = namespace.const&.gsub(KEY_SEPARATOR, PATH_SEPARATOR)

        if namespace_const_path
          "#{namespace_const_path}#{PATH_SEPARATOR}#{path_in_namespace}"
        else
          path_in_namespace
        end
      end

      # @api private
      def loader
        options.fetch(:loader)
      end

      # @api private
      def inflector
        options.fetch(:inflector)
      end

      # @api private
      def auto_register?
        callable_option?(options[:auto_register])
      end

      # @api private
      def memoize?
        callable_option?(options[:memoize])
      end

      private

      def path_in_namespace
        identifier_in_namespace =
          if namespace.key
            identifier.namespaced(from: namespace.key, to: nil)
          else
            identifier
          end

        identifier_in_namespace.key_with_separator(PATH_SEPARATOR)
      end

      def callable_option?(value)
        if value.respond_to?(:call)
          !!value.call(self)
        else
          !!value
        end
      end
    end
  end
end
