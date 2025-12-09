# frozen_string_literal: true

module Hanami
  module CLI
    # @since 0.1.0
    # @api public
    class Error < StandardError
    end

    # @since 2.0.0
    # @api public
    class NotImplementedError < Error
    end

    # @since 2.0.0
    # @api public
    class BundleInstallError < Error
      def initialize(message)
        super("`bundle install' failed\n\n\n#{message.inspect}")
      end
    end

    # @since 2.0.0
    # @api public
    class HanamiInstallError < Error
      def initialize(message)
        super("`hanami install' failed\n\n\n#{message.inspect}")
      end
    end

    # @since 2.1.0
    # @api public
    class HanamiExecError < Error
      def initialize(cmd, message)
        super("`bundle exec hanami #{cmd}' failed\n\n\n#{message.inspect}")
      end
    end

    # @since 2.0.0
    # @api public
    class PathAlreadyExistsError < Error
      def initialize(path)
        super("Cannot create new Hanami app in an existing path: `#{path}'")
      end
    end

    # @api public
    class FileAlreadyExistsError < Error
      ERROR_MESSAGE = <<~ERROR.chomp
        The file `%{file_path}` could not be generated because it already exists.
      ERROR

      def initialize(file_path)
        super(ERROR_MESSAGE % {file_path:})
      end
    end

    # @api public
    class ForbiddenAppNameError < Error
      def initialize(name)
        super("Cannot create new Hanami app with the name: `#{name}'")
      end
    end

    # @since 2.0.0
    # @api public
    class MissingSliceError < Error
      def initialize(slice)
        super("slice `#{slice}' is missing, please generate with `hanami generate slice #{slice}'")
      end
    end

    # @since 2.0.0
    # @api public
    class InvalidURLError < Error
      def initialize(url)
        super("invalid URL: `#{url}'")
      end
    end

    # @since 2.0.0
    # @api public
    class InvalidURLPrefixError < Error
      def initialize(url)
        super("invalid URL prefix: `#{url}'")
      end
    end

    # @since 2.0.0
    # @api public
    class InvalidActionNameError < Error
      def initialize(name)
        super("cannot parse controller and action name: `#{name}'\n\texample: `hanami generate action users.show'")
      end
    end

    # @since 2.0.0
    # @api public
    class UnknownHTTPMethodError < Error
      def initialize(name)
        super("unknown HTTP method: `#{name}'")
      end
    end

    # @since 2.0.0
    # @api public
    class UnsupportedDatabaseSchemeError < Error
      def initialize(scheme)
        super("`#{scheme}' is not a supported db scheme")
      end
    end

    # rubocop:disable Layout/LineLength
    # @since 2.2.0
    # @api public
    class DatabaseNotSupportedError < Error
      def initialize(invalid_database, supported_databases)
        super("`#{invalid_database}' is not a supported database. Supported databases are: #{supported_databases.join(', ')}")
      end
    end
    # rubocop:enable Layout/LineLength

    # @since 2.2.0
    # @api public
    class DatabaseExistenceCheckError < Error
      def initialize(original_message)
        super("Could not check if the database exists. Error message:\n#{original_message}")
      end
    end

    # @since 2.2.0
    # @api public
    class ConflictingOptionsError < Error
      def initialize(option1, option2)
        super("`#{option1}' and `#{option2}' cannot be used together")
      end
    end

    # @since 2.2.0
    # @api public
    class InvalidMigrationNameError < Error
      def initialize(name)
        super(<<~TEXT)
          Invalid migration name: #{name}

          Name must contain only letters, numbers, and underscores.
        TEXT
      end
    end
  end
end
