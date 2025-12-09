# frozen_string_literal: true

require "stringio"

module Dry
  class Files
    class MemoryFileSystem
      # Memory file system node (directory or file)
      #
      # @since 0.1.0
      # @api private
      #
      # File modes implementation inspired by https://www.calleluks.com/flags-bitmasks-and-unix-file-system-permissions-in-ruby/
      class Node
        # @since 0.1.0
        # @api private
        MODE_USER_READ = 0b100000000
        private_constant :MODE_USER_READ

        # @since 0.1.0
        # @api private
        MODE_USER_WRITE = 0b010000000
        private_constant :MODE_USER_WRITE

        # @since 0.1.0
        # @api private
        MODE_USER_EXECUTE = 0b001000000
        private_constant :MODE_USER_EXECUTE

        # @since 0.1.0
        # @api private
        MODE_GROUP_READ = 0b000100000
        private_constant :MODE_GROUP_READ

        # @since 0.1.0
        # @api private
        MODE_GROUP_WRITE = 0b000010000
        private_constant :MODE_GROUP_WRITE

        # @since 0.1.0
        # @api private
        MODE_GROUP_EXECUTE = 0b000001000
        private_constant :MODE_GROUP_EXECUTE

        # @since 0.1.0
        # @api private
        MODE_OTHERS_READ = 0b000000100
        private_constant :MODE_OTHERS_READ

        # @since 0.1.0
        # @api private
        MODE_OTHERS_WRITE = 0b000000010
        private_constant :MODE_OTHERS_WRITE

        # @since 0.1.0
        # @api private
        MODE_OTHERS_EXECUTE = 0b000000001
        private_constant :MODE_OTHERS_EXECUTE

        # Default directory mode: 0755
        #
        # @since 0.1.0
        # @api private
        DEFAULT_DIRECTORY_MODE = MODE_USER_READ | MODE_USER_WRITE | MODE_USER_EXECUTE |
                                 MODE_GROUP_READ | MODE_GROUP_EXECUTE |
                                 MODE_OTHERS_READ | MODE_GROUP_EXECUTE
        private_constant :DEFAULT_DIRECTORY_MODE

        # Default file mode: 0644
        #
        # @since 0.1.0
        # @api private
        DEFAULT_FILE_MODE = MODE_USER_READ | MODE_USER_WRITE | MODE_GROUP_READ | MODE_OTHERS_READ
        private_constant :DEFAULT_FILE_MODE

        # @since 0.1.0
        # @api private
        MODE_BASE = 16
        private_constant :MODE_BASE

        # @since 0.1.0
        # @api private
        ROOT_PATH = "/"
        private_constant :ROOT_PATH

        # Instantiate a root node
        #
        # @return [Dry::Files::MemoryFileSystem::Node] the root node
        #
        # @since 0.1.0
        # @api private
        def self.root
          new(ROOT_PATH)
        end

        # @since 0.1.0
        # @api private
        attr_reader :segment, :mode

        # Instantiate a new node.
        # It's a directory node by default.
        #
        # @param segment [String] the path segment of the node
        # @param mode [Integer] the UNIX mode
        #
        # @return [Dry::Files::MemoryFileSystem::Node] the new node
        #
        # @see #mode=
        #
        # @since 0.1.0
        # @api private
        def initialize(segment, mode = DEFAULT_DIRECTORY_MODE)
          @segment = segment
          @children = nil
          @content = nil

          self.chmod = mode
        end

        # Get a node child
        #
        # @param segment [String] the child path segment
        #
        # @return [Dry::Files::MemoryFileSystem::Node,NilClass] the child node, if found
        #
        # @since 0.1.0
        # @api private
        def get(segment)
          @children&.fetch(segment, nil)
        end

        # Set a node child
        #
        # @param segment [String] the child path segment
        #
        # @since 0.1.0
        # @api private
        def set(segment)
          @children ||= {}
          @children[segment] ||= self.class.new(segment)
        end

        # Unset a node child
        #
        # @param segment [String] the child path segment
        #
        # @raise [Dry::Files::UnknownMemoryNodeError] if the child node cannot be found
        #
        # @since 0.1.0
        # @api private
        def unset(segment)
          @children ||= {}
          raise UnknownMemoryNodeError, segment unless @children.key?(segment)

          @children.delete(segment)
        end

        # Check if node is a directory
        #
        # @return [TrueClass,FalseClass] the result of the check
        #
        # @since 0.1.0
        # @api private
        def directory?
          !file?
        end

        # Check if node is a file
        #
        # @return [TrueClass,FalseClass] the result of the check
        #
        # @since 0.1.0
        # @api private
        def file?
          !@content.nil?
        end

        # Read file contents
        #
        # @return [String] the file contents
        #
        # @raise [Dry::Files::NotMemoryFileError] if node isn't a file
        #
        # @since 0.1.0
        # @api private
        def read
          raise NotMemoryFileError, segment unless file?

          @content.rewind
          @content.read
        end

        # Read file content lines
        #
        # @return [Array<String>] the file content lines
        #
        # @raise [Dry::Files::NotMemoryFileError] if node isn't a file
        #
        # @since 0.1.0
        # @api private
        def readlines
          raise NotMemoryFileError, segment unless file?

          @content.rewind
          @content.readlines
        end

        # Write file contents
        # IMPORTANT: This operation turns a node into a file
        #
        # @param content [String, Array<String>] the file content
        #
        # @raise [Dry::Files::NotMemoryFileError] if node isn't a file
        #
        # @since 0.1.0
        # @api private
        def write(content)
          content = case content
                    when String
                      content
                    when Array
                      array_to_string(content)
                    when NilClass
                      EMPTY_CONTENT
                    end

          @content = StringIO.new(content)
          @mode = DEFAULT_FILE_MODE
        end

        # Set UNIX mode
        # It accepts base 2, 8, 10, and 16 numbers
        #
        # @param mode [Integer] the file mode
        #
        # @since 0.1.0
        # @api private
        def chmod=(mode)
          @mode = mode.to_s(MODE_BASE).hex
        end

        # Check if node is executable for user
        #
        # @return [TrueClass,FalseClass] the result of the check
        #
        # @since 0.1.0
        # @api private
        def executable?
          (mode & MODE_USER_EXECUTE).positive?
        end

        # @since 0.3.0
        # @api private
        def array_to_string(content)
          content.map do |line|
            line.sub(NEW_LINE_MATCHER, EMPTY_CONTENT)
          end.join(NEW_LINE) + NEW_LINE
        end
      end
    end
  end
end
