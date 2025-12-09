# frozen_string_literal: true

module Hanami
  module Utils
    # Ordered file list, consistent across operating systems
    #
    # @since 0.9.0
    module FileList
      # Returns an ordered list of files, consistent across operating systems
      #
      # It has the same signature of <tt>Dir.glob</tt>, it just guarantees to
      # order the results before to return them.
      #
      # @since 0.9.0
      #
      # @see https://ruby-doc.org/core/Dir.html#method-c-glob
      #
      # @example simple usage
      #   require "hanami/utils/file_list"
      #
      #   Hanami::Utils::FileList["spec/support/fixtures/file_list/*.rb"]
      #   # => [
      #     "spec/support/fixtures/file_list/a.rb",
      #     "spec/support/fixtures/file_list/aa.rb",
      #     "spec/support/fixtures/file_list/ab.rb"
      #   ]
      #
      # @example token usage
      #   require "hanami/utils/file_list"
      #
      #   Hanami::Utils::FileList["spec", "support", "fixtures", "file_list", "*.rb"]
      #   # => [
      #     "spec/support/fixtures/file_list/a.rb",
      #     "spec/support/fixtures/file_list/aa.rb",
      #     "spec/support/fixtures/file_list/ab.rb"
      #   ]
      def self.[](*args)
        Dir.glob(::File.join(*args)).sort!
      end
    end
  end
end
