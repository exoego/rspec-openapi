# frozen_string_literal: true

module Dry
  class Files
    # Cross Operating System path
    #
    # It's used by the memory adapter to ensure that hardcoded string paths
    # are transformed into portable paths that respect the Operating System
    # directory separator.
    module Path
      # @since 0.1.0
      # @api private
      SEPARATOR = ::File::SEPARATOR

      # @since 0.1.0
      # @api private
      EMPTY_TOKEN = ""
      private_constant :EMPTY_TOKEN

      class << self
        # Transform the given path into a path that respect the Operating System
        # directory separator.
        #
        # @param path [String,Pathname,Array<String,Pathname>] the path to transform
        #
        # @return [String] the resulting path
        #
        # @since 0.1.0
        # @api private
        #
        # @example Portable Path
        #   require "dry/files/path"
        #
        #   path = "path/to/file"
        #
        #   Dry::Files::Path.call(path)
        #     # => "path/to/file" on UNIX based Operating System
        #
        #   Dry::Files::Path.call(path)
        #     # => "path\to\file" on Windows Operating System
        #
        # @example Join Nested Tokens
        #   require "dry/files/path"
        #
        #   path = ["path", ["to", ["nested", "file"]]]
        #
        #   Dry::Files::Path.call(path)
        #     # => "path/to/nested/file" on UNIX based Operating System
        #
        #   Dry::Files::Path.call(path)
        #     # => "path\to\nested\file" on Windows Operating System
        #
        # @example Separator path
        #   require "dry/files/path"
        #
        #   path = ::File::SEPARATOR
        #
        #   Dry::Files::Path.call(path)
        #     # => ""
        def call(*path)
          path = Array(path).flatten
          tokens = path.map do |token|
            split(token)
          end

          tokens
            .flatten
            .join(SEPARATOR)
        end
        alias_method :[], :call
      end

      # Split path according to the current Operating System directory separator
      #
      # @param path [String,Pathname] the path to split
      #
      # @return [Array<String>] the split path
      #
      # @since 0.1.0
      # @api private
      def self.split(path)
        return EMPTY_TOKEN if path == SEPARATOR

        path.to_s.split(%r{\\|/})
      end

      # Check if given path is absolute
      #
      # @param path [String,Pathname] the path to check
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.1.0
      # @api private
      def self.absolute?(path)
        path.start_with?(SEPARATOR)
      end

      # Returns all the path, except for the last token
      #
      # @param path [String,Pathname] the path to extract directory name from
      #
      # @return [String] the directory name
      #
      # @since 0.1.0
      # @api private
      def self.dirname(path)
        ::File.dirname(path)
      end
    end
  end
end
