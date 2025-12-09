# frozen_string_literal: true

require "dry/files"

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    class Files < Dry::Files
      # @since 2.0.0
      # @api private
      def initialize(out: $stdout, **args)
        super(**args)
        @out = out
      end

      # @api private
      def create(path, *content)
        raise FileAlreadyExistsError.new(path) if exist?(path)

        write(path, *content)
      end

      # @since 2.0.0
      # @api private
      def write(path, *content)
        already_exists = exist?(path)

        super

        delete_keepfiles(path) unless already_exists

        if already_exists
          updated(path)
        else
          created(path)
        end
      end

      # @since 2.0.0
      # @api private
      def mkdir(path)
        return if exist?(path)

        super
        created(dir_path(path))
      end

      # @since 2.0.0
      # @api private
      def chdir(path, &blk)
        within_folder(path)
        super
      end

      def touch(path)
        return if exist?(path)

        super
        created(path)
      end

      private

      attr_reader :out

      # Removes .keep files in any directories leading up to the given path.
      #
      # Does not attempt to remove `.keep` files in the following scenarios:
      #   - When the given path is a `.keep` file itself.
      #   - When the given path is absolute, since ascending up this path may lead to removal of
      #     files outside the Hanami project directory.
      def delete_keepfiles(path)
        path = Pathname(path)

        return if path.absolute?
        return if path.relative_path_from(path.dirname).to_s == ".keep"

        path.dirname.ascend do |part|
          keepfile = (part + ".keep").to_path
          delete(keepfile) if exist?(keepfile)
        end
      end

      def updated(path)
        out.puts "Updated #{path}"
      end

      def created(path)
        out.puts "Created #{path}"
      end

      def within_folder(path)
        out.puts "-> Within #{dir_path(path)}"
      end

      def dir_path(path)
        path + ::File::SEPARATOR
      end
    end
  end
end
