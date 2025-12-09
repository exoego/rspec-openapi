# frozen_string_literal: true

# dry-rb is a collection of next-generation Ruby libraries
#
# @api public
# @since 0.1.0
module Dry
  # File manipulations
  #
  # @since 0.1.0
  # @api public
  class Files
    require_relative "files/version"
    require_relative "files/error"
    require_relative "files/adapter"

    # @since 0.3.0
    # @api public
    OPEN_MODE = ::File::RDWR

    # @since 0.3.0
    # @api public
    WRITE_MODE = (::File::CREAT | ::File::WRONLY | ::File::TRUNC).freeze

    # Creates a new instance
    #
    # Memory file system is experimental
    #
    # @param memory [TrueClass,FalseClass] use in-memory, ephemeral file system
    # @param adapter [Dry::FileSystem]
    #
    # @return [Dry::Files] a new files instance
    #
    # @since 0.1.0
    # @api public
    def initialize(memory: false, adapter: Adapter.call(memory: memory))
      @adapter = adapter
    end

    # Read file content
    #
    # @param path [String,Pathname] the path to file
    #
    # @return [String] the file contents
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    #
    # TODO: allow buffered read
    def read(path)
      adapter.read(path)
    end

    # Creates an empty file for the given path.
    # All the intermediate directories are created.
    # If the path already exists, it doesn't change the contents
    #
    # @param path [String,Pathname] the path to file
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    def touch(path)
      adapter.touch(path)
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
    # @api public
    def write(path, *content)
      adapter.write(path, *content)
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
    # @api public
    def chmod(path, mode)
      raise Dry::Files::Error, "mode should be an integer (e.g. 0o755)" unless mode.is_a?(Integer)

      adapter.chmod(path, mode)
    end

    # Returns a new string formed by joining the strings using Operating
    # System path separator
    #
    # @param path [Array<String,Pathname>] path tokens
    #
    # @return [String] the joined path
    #
    # @since 0.1.0
    # @api public
    def join(*path)
      adapter.join(*path)
    end

    # Converts a path to an absolute path.
    #
    # Relative paths are referenced from the current working directory of
    # the process unless `dir` is given.
    #
    # @param path [String,Pathname] the path to the file
    # @param dir [String,Pathname] the base directory
    #
    # @return [String] the expanded path
    #
    # @since 0.1.0
    def expand_path(path, dir = pwd)
      adapter.expand_path(path, dir)
    end

    # Returns the name of the current working directory.
    #
    # @return [String] the current working directory.
    #
    # @since 0.1.0
    def pwd
      adapter.pwd
    end

    # Opens (or creates) a new file for both read/write operations
    #
    # @param path [String] the target file
    # @param mode [String,Integer] Ruby file open mode
    # @param args [Array<Object>] ::File.open args
    # @param blk [Proc] the block to yield
    #
    # @yieldparam [File,Dry::Files::MemoryFileSystem::Node] the opened file
    #
    # @return [File,Dry::Files::MemoryFileSystem::Node] the opened file
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    def open(path, mode = OPEN_MODE, *args, &blk)
      adapter.open(path, mode, *args, &blk)
    end

    # Temporary changes the current working directory of the process to the
    # given path and yield the given block.
    #
    # @param path [String,Pathname] the target directory
    # @param blk [Proc] the code to execute with the target directory
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    def chdir(path, &blk)
      adapter.chdir(path, &blk)
    end

    # Creates a directory for the given path.
    # It assumes that all the tokens in `path` are meant to be a directory.
    # All the intermediate directories are created.
    #
    # @param path [String,Pathname] the path to directory
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    #
    # @see #mkdir_p
    #
    # @example
    #   require "dry/files"
    #
    #   Dry::Files.new.mkdir("path/to/directory")
    #     # => creates the `path/to/directory` directory
    #
    #   # WRONG this isn't probably what you want, check `.mkdir_p`
    #   Dry::Files.new.mkdir("path/to/file.rb")
    #     # => creates the `path/to/file.rb` directory
    def mkdir(path)
      adapter.mkdir(path)
    end

    # Creates a directory for the given path.
    # It assumes that all the tokens, but the last, in `path` are meant to be
    # a directory, whereas the last is meant to be a file.
    # All the intermediate directories are created.
    #
    # @param path [String,Pathname] the path to directory
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    #
    # @see #mkdir
    #
    # @example
    #   require "dry/files"
    #
    #   Dry::Files.new.mkdir_p("path/to/file.rb")
    #     # => creates the `path/to` directory, but NOT `file.rb`
    #
    #   # WRONG it doesn't create the last directory, check `.mkdir`
    #   Dry::Files.new.mkdir_p("path/to/directory")
    #     # => creates the `path/to` directory
    def mkdir_p(path)
      adapter.mkdir_p(path)
    end

    # Copies source into destination.
    # All the intermediate directories are created.
    # If the destination already exists, it overrides the contents.
    #
    # @param source [String,Pathname] the path to the source file
    # @param destination [String,Pathname] the path to the destination file
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    def cp(source, destination)
      adapter.cp(source, destination)
    end

    # Deletes given path (file).
    #
    # @param path [String,Pathname] the path to file
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    def delete(path)
      adapter.rm(path)
    end

    # Deletes given path (directory).
    #
    # @param path [String,Pathname] the path to file
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @since 0.1.0
    # @api public
    def delete_directory(path)
      adapter.rm_rf(path)
    end

    # Checks if `path` exist
    #
    # @param path [String,Pathname] the path to file
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @since 0.1.0
    # @api public
    #
    # @example
    #   require "dry/files"
    #
    #   Dry::Files.new.exist?(__FILE__) # => true
    #   Dry::Files.new.exist?(__dir__)  # => true
    #
    #   Dry::Files.new.exist?("missing_file") # => false
    def exist?(path)
      adapter.exist?(path)
    end

    # Checks if `path` is a directory
    #
    # @param path [String,Pathname] the path to directory
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @since 0.1.0
    # @api public
    #
    # @example
    #   require "dry/files"
    #
    #   Dry::Files.new.directory?(__dir__)  # => true
    #   Dry::Files.new.directory?(__FILE__) # => false
    #
    #   Dry::Files.new.directory?("missing_directory") # => false
    def directory?(path)
      adapter.directory?(path)
    end

    # Checks if `path` is an executable
    #
    # @param path [String,Pathname] the path to file
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @since 0.1.0
    # @api public
    #
    # @example
    #   require "dry/files"
    #
    #   Dry::Files.new.executable?("/path/to/ruby") # => true
    #   Dry::Files.new.executable?(__FILE__)        # => false
    #
    #   Dry::Files.new.directory?("missing_file") # => false
    def executable?(path)
      adapter.executable?(path)
    end

    # Adds a new line at the top of the file
    #
    # @param path [String,Pathname] the path to file
    # @param line [String] the line to add
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @see #append
    #
    # @since 0.1.0
    # @api public
    def unshift(path, line)
      content = adapter.readlines(path)
      content.unshift(newline(line))

      write(path, content)
    end

    # Adds a new line at the bottom of the file
    #
    # @param path [String,Pathname] the path to file
    # @param contents [String] the contents to add
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    #
    # @see #unshift
    #
    # @since 0.1.0
    # @api public
    def append(path, contents)
      mkdir_p(path)
      touch(path)

      content = adapter.readlines(path)
      content << newline unless newline?(content.last)
      content << newline(contents)

      write(path, content)
    end

    # Replace first line in `path` that contains `target` with `replacement`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param replacement [String] the replacement
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #replace_last_line
    #
    # @since 0.1.0
    # @api public
    def replace_first_line(path, target, replacement)
      content = adapter.readlines(path)
      content[index(content, path, target)] = newline(replacement)

      write(path, content)
    end

    # Replace last line in `path` that contains `target` with `replacement`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param replacement [String] the replacement
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #replace_first_line
    #
    # @since 0.1.0
    # @api public
    def replace_last_line(path, target, replacement)
      content = adapter.readlines(path)
      content[-index(content.reverse, path, target) - CONTENT_OFFSET] = newline(replacement)

      write(path, content)
    end

    # Inject `contents` in `path` before `target`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param contents [String] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #inject_line_after
    # @see #inject_line_before_last
    # @see #inject_line_after_last
    #
    # @since 0.1.0
    # @api public
    def inject_line_before(path, target, contents)
      _inject_line_before(path, target, contents, method(:index))
    end

    # Inject `contents` in `path` after last `target`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param contents [String] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #inject_line_before
    # @see #inject_line_after
    # @see #inject_line_after_last
    #
    # @since 0.1.0
    # @api public
    def inject_line_before_last(path, target, contents)
      _inject_line_before(path, target, contents, method(:rindex))
    end

    # Inject `contents` in `path` after `target`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param contents [String] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #inject_line_before
    # @see #inject_line_before_last
    # @see #inject_line_after_last
    #
    # @since 0.1.0
    # @api public
    def inject_line_after(path, target, contents)
      _inject_line_after(path, target, contents, method(:index))
    end

    # Inject `contents` in `path` after last `target`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to replace
    # @param contents [String] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @see #inject_line_before
    # @see #inject_line_after
    # @see #inject_line_before_last
    #
    # @since 0.1.0
    # @api public
    def inject_line_after_last(path, target, contents)
      _inject_line_after(path, target, contents, method(:rindex))
    end

    # Inject `contents` in `path` within the first Ruby block that matches `target`.
    # The given `contents` will appear at the TOP of the Ruby block.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target matcher for Ruby block
    # @param contents [String,Array<String>] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @since 0.1.0
    # @api public
    #
    # @example Inject a single line
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject a single line
    #   files.inject_line_at_block_top(path, /configure/, %(load_path.unshift("lib")))
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     load_path.unshift("lib")
    #   #     root __dir__
    #   #   end
    #   # end
    #
    # @example Inject multiple lines
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject multiple lines
    #   files.inject_line_at_block_top(path,
    #                                  /configure/,
    #                                  [%(load_path.unshift("lib")), "settings.load!"])
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     load_path.unshift("lib")
    #   #     settings.load!
    #   #     root __dir__
    #   #   end
    #   # end
    #
    # @example Inject a block
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject a block
    #   block = <<~BLOCK
    #     settings do
    #       load!
    #     end
    #   BLOCK
    #   files.inject_line_at_block_top(path, /configure/, block)
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     settings do
    #   #       load!
    #   #     end
    #   #     root __dir__
    #   #   end
    #   # end
    def inject_line_at_block_top(path, target, *contents)
      content  = adapter.readlines(path)
      starting = index(content, path, target)
      offset   = SPACE * (content[starting][SPACE_MATCHER].bytesize + INDENTATION)

      contents = Array(contents).flatten
      contents = _offset_block_lines(contents, offset)

      content.insert(starting + CONTENT_OFFSET, contents)
      write(path, content)
    end

    # Inject `contents` in `path` within the first Ruby block that matches `target`.
    # The given `contents` will appear at the BOTTOM of the Ruby block.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target matcher for Ruby block
    # @param contents [String,Array<String>] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @since 0.1.0
    # @api public
    #
    # @example Inject a single line
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject a single line
    #   files.inject_line_at_block_bottom(path, /configure/, %(load_path.unshift("lib")))
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #     load_path.unshift("lib")
    #   #   end
    #   # end
    #
    # @example Inject multiple lines
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject multiple lines
    #   files.inject_line_at_block_bottom(path,
    #                                     /configure/,
    #                                     [%(load_path.unshift("lib")), "settings.load!"])
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #     load_path.unshift("lib")
    #   #     settings.load!
    #   #   end
    #   # end
    #
    # @example Inject a block
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   # inject a block
    #   block = <<~BLOCK
    #     settings do
    #       load!
    #     end
    #   BLOCK
    #   files.inject_line_at_block_bottom(path, /configure/, block)
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   configure do
    #   #     root __dir__
    #   #     settings do
    #   #       load!
    #   #     end
    #   #   end
    #   # end
    def inject_line_at_block_bottom(path, target, *contents)
      content   = adapter.readlines(path)
      starting  = index(content, path, target)
      line      = content[starting]
      delimiter = if line.match?(INLINE_OPEN_BLOCK_MATCHER)
                    INLINE_BLOCK_DELIMITER
                  else
                    BLOCK_DELIMITER
                  end
      target    = content[starting..]
      ending    = closing_block_index(target, starting, path, line, delimiter)
      offset    = SPACE * (content[ending][SPACE_MATCHER].bytesize + INDENTATION)

      contents = Array(contents).flatten
      contents = _offset_block_lines(contents, offset)

      content.insert(ending, contents)
      write(path, content)
    end

    # Inject `contents` in `path` at the bottom of the Ruby class that matches `target`.
    # The given `contents` will appear at the BOTTOM of the Ruby class.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target matcher for Ruby class
    # @param contents [String,Array<String>] the contents to inject
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @since 0.4.0
    # @api public
    #
    # @example Inject a single line
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "config/application.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   # end
    #
    #   # inject a single line
    #   files.inject_line_at_class_bottom(path, /Application/, %(attr_accessor :name))
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Application
    #   #   attr_accessor :name
    #   # end
    #
    # @example Inject multiple lines
    #   require "dry/files"
    #
    #   files = Dry::Files.new
    #   path = "math.rb"
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Math
    #   # end
    #
    #   # inject multiple lines
    #   files.inject_line_at_class_bottom(path,
    #                                     /Math/,
    #                                     ["def sum(a, b)", "  a + b", "end"])
    #
    #   File.read(path)
    #   # # frozen_string_literal: true
    #   #
    #   # class Math
    #   #   def sum(a, b)
    #   #     a + b
    #   #   end
    #   # end
    def inject_line_at_class_bottom(path, target, *contents)
      content   = adapter.readlines(path)
      starting  = index(content, path, target)
      line      = content[starting]
      target    = content[starting..]
      ending    = closing_class_index(target, starting, path, line, BLOCK_DELIMITER)
      offset    = SPACE * (content[ending][SPACE_MATCHER].bytesize + INDENTATION)

      contents = Array(contents).flatten
      contents = _offset_block_lines(contents, offset)

      content.insert(ending, contents)
      write(path, content)
    end

    # Removes line from `path`, matching `target`.
    #
    # @param path [String,Pathname] the path to file
    # @param target [String,Regexp] the target to remove
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @since 0.1.0
    # @api public
    def remove_line(path, target)
      content = adapter.readlines(path)
      i       = index(content, path, target)

      content.delete_at(i)
      write(path, content)
    end

    # Removes `target` block from `path`
    #
    # @param path [String,Pathname] the path to file
    # @param target [String] the target block to remove
    #
    # @raise [Dry::Files::IOError] in case of I/O error
    # @raise [Dry::Files::MissingTargetError] if `target` cannot be found in `path`
    #
    # @since 0.1.0
    # @api public
    #
    # @example
    #   require "dry/files"
    #
    #   puts File.read("app.rb")
    #
    #   # class App
    #   #   configure do
    #   #     root __dir__
    #   #   end
    #   # end
    #
    #   Dry::Files.new.remove_block("app.rb", "configure")
    #
    #   puts File.read("app.rb")
    #
    #   # class App
    #   # end
    def remove_block(path, target)
      content  = adapter.readlines(path)
      starting = index(content, path, target)
      line     = content[starting]
      size     = line[SPACE_MATCHER].bytesize
      closing  = (SPACE * size) +
                 (target.match?(INLINE_OPEN_BLOCK_MATCHER) ? INLINE_CLOSE_BLOCK : CLOSE_BLOCK)
      ending   = starting + index(content[starting..-CONTENT_OFFSET], path, closing)

      content.slice!(starting..ending)
      write(path, content)

      remove_block(path, target) if match?(content, target)
    end

    private

    # @since 0.3.0
    # @api private
    class Delimiter
      # @since 1.0.2
      # @api private
      SPACE_MATCHER_GENERAL = /[[:space:]]*/
      private_constant :SPACE_MATCHER_GENERAL

      # @since 0.3.0
      # @api private
      attr_reader :opening, :closing

      # @since 0.3.0
      # @api private
      def initialize(name, opening, closing)
        @name = name
        @opening = opening
        @closing = closing
        freeze
      end

      # @since 1.0.2
      # @api private
      def opening_matcher
        matcher(opening)
      end

      # @since 1.0.2
      # @api private
      def closing_matcher
        matcher(closing)
      end

      private

      # @since 1.0.2
      # @api private
      def matcher(delimiter)
        /#{SPACE_MATCHER_GENERAL}\b#{delimiter}\b(?:#{SPACE_MATCHER_GENERAL}|#{NEW_LINE_MATCHER})/
      end
    end

    # @since 0.1.0
    # @api private
    NEW_LINE = $/ # rubocop:disable Style/SpecialGlobalVars
    private_constant :NEW_LINE

    # @since 0.3.0
    # @api private
    NEW_LINE_MATCHER = /#{NEW_LINE}\z/
    private_constant :NEW_LINE_MATCHER

    # @since 0.3.0
    # @api private
    EMPTY_LINE = /\A\z/
    private_constant :EMPTY_LINE

    # @since 0.1.0
    # @api private
    CONTENT_OFFSET = 1
    private_constant :CONTENT_OFFSET

    # @since 0.1.0
    # @api private
    SPACE = " "
    private_constant :SPACE

    # @since 0.1.0
    # @api private
    INDENTATION = 2
    private_constant :INDENTATION

    # @since 0.1.0
    # @api private
    SPACE_MATCHER = /\A[[:space:]]*/
    private_constant :SPACE_MATCHER

    # @since 0.3.0
    # @api private
    INLINE_OPEN_BLOCK = "{"
    private_constant :INLINE_OPEN_BLOCK

    # @since 0.1.0
    # @api private
    INLINE_CLOSE_BLOCK = "}"
    private_constant :INLINE_CLOSE_BLOCK

    # @since 0.3.0
    # @api private
    OPEN_BLOCK = "do"
    private_constant :OPEN_BLOCK

    # @since 0.1.0
    # @api private
    CLOSE_BLOCK = "end"
    private_constant :CLOSE_BLOCK

    # @since 0.1.0
    # @api private
    INLINE_OPEN_BLOCK_MATCHER = INLINE_CLOSE_BLOCK
    private_constant :INLINE_OPEN_BLOCK_MATCHER

    # @since 0.3.0
    # @api private
    INLINE_BLOCK_DELIMITER = Delimiter.new("InlineBlockDelimiter",
                                           INLINE_OPEN_BLOCK, INLINE_CLOSE_BLOCK)
    private_constant :INLINE_BLOCK_DELIMITER

    # @since 0.3.0
    # @api private
    BLOCK_DELIMITER = Delimiter.new("BlockDelimiter", OPEN_BLOCK, CLOSE_BLOCK)
    private_constant :BLOCK_DELIMITER

    # @since 0.1.0
    # @api private
    attr_reader :adapter

    # @since 0.1.0
    # @api private
    def newline(line = nil)
      return line if line.to_s.end_with?(NEW_LINE)

      "#{line}#{NEW_LINE}"
    end

    # @since 0.1.0
    # @api private
    def newline?(content)
      content&.end_with?(NEW_LINE)
    end

    # @since 0.1.0
    # @api private
    def match?(content, target)
      !line_number(content, target).nil?
    end

    # @since 0.1.0
    # @api private
    def index(content, path, target)
      line_number(content, target) or
        raise MissingTargetError.new(target, path)
    end

    # @since 0.1.0
    # @api private
    def rindex(content, path, target)
      line_number(content, target, finder: content.method(:rindex)) or
        raise MissingTargetError.new(target, path)
    end

    # @since 0.3.0
    # @api private
    def closing_block_index(content, starting, path, target, delimiter, count_offset = 0) # rubocop:disable Metrics/ParameterLists
      blocks_count = content.count { |line| line.match?(delimiter.opening_matcher) } + count_offset
      matching_line = content.find do |line|
        blocks_count -= 1 if line.match?(delimiter.closing_matcher)
        line if blocks_count.zero?
      end

      (content.index(matching_line) or
        raise MissingTargetError.new(target, path)) + starting
    end

    # @since 0.4.0
    # @api private
    def closing_class_index(content, starting, path, target, delimiter)
      closing_block_index(content, starting, path, target, delimiter, 1)
    end

    # @since 0.1.0
    # @api private
    def _inject_line_before(path, target, contents, finder)
      content = adapter.readlines(path)
      i       = finder.call(content, path, target)

      content.insert(i, newline(contents))
      write(path, content)
    end

    # @since 0.1.0
    # @api private
    def _inject_line_after(path, target, contents, finder)
      content = adapter.readlines(path)
      i       = finder.call(content, path, target)

      content.insert(i + CONTENT_OFFSET, newline(contents))
      write(path, content)
    end

    # @since 0.1.0
    # @api private
    def _offset_block_lines(contents, offset)
      contents.map do |line|
        if line.match?(NEW_LINE)
          line = line.split(NEW_LINE)
          _offset_block_lines(line, offset)
        elsif line.match?(EMPTY_LINE)
          line + NEW_LINE
        else
          offset + line + NEW_LINE
        end
      end.join
    end

    # @since 0.1.0
    # @api private
    def line_number(content, target, finder: content.method(:index))
      finder.call do |l|
        case target
        when ::String
          l.include?(target)
        when Regexp
          l =~ target
        end
      end
    end
  end
end
