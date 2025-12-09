# frozen_string_literal: true

module Dry
  class Files
    # @since 0.1.0
    # @api private
    class Adapter
      # @since 0.1.0
      # @api private
      def self.call(memory:)
        if memory
          require_relative "./memory_file_system"
          MemoryFileSystem.new
        else
          require_relative "./file_system"
          FileSystem.new
        end
      end
    end
  end
end
