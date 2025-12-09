# frozen_string_literal: true

require "fileutils"

module Dry
  class Files
    # File System abstraction to support `Dry::Files`
    #
    # @since 0.1.0
    # @api private
    class FileSystem
      # @since 0.1.0
      # @api private
      attr_reader :file

      # @since 0.1.0
      # @api private
      attr_reader :file_utils

      # Creates a new instance
      #
      # @param file [Class]
      # @param file_utils [Class]
      #
      # @return [Dry::Files::FileSystem]
      #
      # @since 0.1.0
      def initialize(file: File, file_utils: FileUtils)
        @file = file
        @file_utils = file_utils
      end

      # Opens (or creates) a new file for both read/write operations.
      #
      # If the file doesn't exist, it creates a new one.
      #
      # @see https://ruby-doc.org/core/File.html#method-c-open
      #
      # @param path [String] the target file
      # @param mode [String,Integer] Ruby file open mode
      # @param args [Array<Object>] ::File.open args
      # @param blk [Proc] the block to yield
      #
      # @yieldparam [::File] the opened file
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      def open(path, mode, *args, &blk)
        touch(path)

        with_error_handling do
          file.open(path, mode, *args, &blk)
        end
      end

      # Opens the file, optionally seeks to the given offset, then returns
      # length bytes (defaulting to the rest of the file).
      #
      # Read ensures the file is closed before returning.
      #
      # @see https://ruby-doc.org/core/IO.html#method-c-read
      #
      # @param path [String, Array<String>] the target path
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def read(path, *args, **kwargs)
        with_error_handling do
          file.read(path, *args, **kwargs)
        end
      end

      # Reads the entire file specified by name as individual lines,
      # and returns those lines in an array
      #
      # @see https://ruby-doc.org/core/IO.html#method-c-readlines
      #
      # @param path [String] the file to read
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def readlines(path, *args)
        with_error_handling do
          file.readlines(path, *args)
        end
      end

      # Updates modification time (mtime) and access time (atime) of file(s)
      # in list.
      #
      # Files are created if they don’t exist.
      #
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-touch
      #
      # @param path [String, Array<String>] the target path
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def touch(path, **kwargs)
        raise IOError, Errno::EISDIR.new(path.to_s) if directory?(path)

        with_error_handling do
          mkdir_p(path)
          file_utils.touch(path, **kwargs)
        end
      end

      # Creates a new file or rewrites the contents
      # of an existing file for the given path and content
      # All the intermediate directories are created.
      #
      # @param path [String,Pathname] the path to file
      # @param content [String, Array<String>] the content to write
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def write(path, *content)
        mkdir_p(path)

        self.open(path, WRITE_MODE) do |f|
          f.write(Array(content).flatten.join)
        end
      end

      # Sets UNIX permissions of the file at the given path.
      #
      # Accepts permissions in numeric mode only, best provided as octal numbers matching the
      # standard UNIX octal permission modes, such as `0o544` for a file writeable by its owner and
      # readable by others, or `0o755` for a file writeable by its owner and executable by everyone.
      #
      # @param path [String,Pathname] the path to the file
      # @param mode [Integer] the UNIX permissions mode
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 1.1.0
      # @api private
      def chmod(path, mode)
        with_error_handling do
          file_utils.chmod(mode, path)
        end
      end

      # Returns a new string formed by joining the strings using Operating
      # System path separator
      #
      # @see https://ruby-doc.org/core/File.html#method-c-join
      #
      # @param path [Array<String,Pathname>] path tokens
      #
      # @return [String] the joined path
      #
      # @since 0.1.0
      # @api private
      def join(*path)
        file.join(*path)
      end

      # Converts a path to an absolute path.
      #
      # @see https://ruby-doc.org/core/File.html#method-c-expand_path
      #
      # @param path [String,Pathname] the path to the file
      # @param dir [String,Pathname] the base directory
      #
      # @since 0.1.0
      # @api private
      def expand_path(path, dir)
        file.expand_path(path, dir)
      end

      # Returns the name of the current working directory.
      #
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-pwd
      #
      # @return [String] the current working directory.
      #
      # @since 0.1.0
      # @api private
      def pwd
        file_utils.pwd
      end

      # Temporary changes the current working directory of the process to the
      # given path and yield the given block.
      #
      # The argument `path` is intended to be a **directory**.
      #
      # @see https://ruby-doc.org/stdlib-3.0.0/libdoc/fileutils/rdoc/FileUtils.html#method-i-cd
      #
      # @param path [String,Pathname] the target directory
      # @param blk [Proc] the code to execute with the target directory
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def chdir(path, &blk)
        with_error_handling do
          file_utils.chdir(path, &blk)
        end
      end

      # Creates a directory and all its parent directories.
      #
      # The argument `path` is intended to be a **directory** that you want to
      # explicitly create.
      #
      # @see #mkdir_p
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-mkdir_p
      #
      # @param path [String] the directory to create
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @example
      #   require "dry/cli/utils/files/file_system"
      #
      #   fs = Dry::Files::FileSystem.new
      #   fs.mkdir("/usr/var/project")
      #   # creates all the directory structure (/usr/var/project)
      #
      # @since 0.1.0
      # @api private
      def mkdir(path, **kwargs)
        with_error_handling do
          file_utils.mkdir_p(path, **kwargs)
        end
      end

      # Creates a directory and all its parent directories.
      #
      # The argument `path` is intended to be a **file**, where its
      # directory ancestors will be implicitly created.
      #
      # @see #mkdir
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-mkdir
      #
      # @param path [String] the file that will be in the directories that
      #                      this method creates
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @example
      #   require "dry/cli/utils/files/file_system"
      #
      #   fs = Dry::Files::FileSystem.new
      #   fs.mkdir("/usr/var/project/file.rb")
      #   # creates all the directory structure (/usr/var/project)
      #   # where file.rb will eventually live
      #
      # @since 0.1.0
      # @api private
      def mkdir_p(path, **kwargs)
        mkdir(
          file.dirname(path), **kwargs
        )
      end

      # Copies file content from `source` to `destination`
      # All the intermediate `destination` directories are created.
      #
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-cp
      #
      # @param source [String] the file(s) or directory to copy
      # @param destination [String] the directory destination
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def cp(source, destination, **kwargs)
        mkdir_p(destination)

        with_error_handling do
          file_utils.cp(source, destination, **kwargs)
        end
      end

      # Removes (deletes) a file
      #
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-rm
      #
      # @see #rm_rf
      #
      # @param path [String] the file to remove
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def rm(path, **kwargs)
        with_error_handling do
          file_utils.rm(path, **kwargs)
        end
      end

      # Removes (deletes) a directory
      #
      # @see https://ruby-doc.org/stdlib/libdoc/fileutils/rdoc/FileUtils.html#method-c-remove_entry_secure
      #
      # @param path [String] the directory to remove
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def rm_rf(path, *args)
        with_error_handling do
          file_utils.remove_entry_secure(path, *args)
        end
      end

      # Check if the given path exist.
      #
      # @see https://ruby-doc.org/core/File.html#method-c-exist-3F
      #
      # @param path [String,Pathname] the file to check
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.1.0
      # @api private
      def exist?(path)
        file.exist?(path)
      end

      # Check if the given path is a directory.
      #
      # @see https://ruby-doc.org/core/File.html#method-c-directory-3F
      #
      # @param path [String,Pathname] the directory to check
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.1.0
      # @api private
      def directory?(path)
        file.directory?(path)
      end

      # Check if the given path is an executable.
      #
      # @see https://ruby-doc.org/core/File.html#method-c-executable-3F
      #
      # @param path [String,Pathname] the path to check
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.1.0
      # @api private
      def executable?(path)
        file.executable?(path)
      end

      private

      # Catch `SystemCallError` and re-raise a `Dry::Files::IOError`.
      #
      # `SystemCallError` is parent for all the `Errno::*` Ruby exceptions.
      # These class of exceptions are raised in case of I/O error.
      #
      # @see https://ruby-doc.org/core/SystemCallError.html
      # @see https://ruby-doc.org/core/Errno.html
      #
      # @raise [Dry::Files::IOError] in case of I/O error
      #
      # @since 0.1.0
      # @api private
      def with_error_handling
        yield
      rescue SystemCallError => e
        raise IOError, e
      end
    end
  end
end
