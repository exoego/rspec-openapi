# frozen_string_literal: true

require_relative "version"

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    module Generators
      # @since 2.0.0
      # @api private
      class Context
        # @since 2.0.0
        # @api private
        def initialize(inflector, app, **options)
          @inflector = inflector
          @app = app
          @options = options
        end

        # @since 2.0.0
        # @api private
        def ctx
          binding
        end

        def hanami_gem(name)
          gem_name = name == "hanami" ? "hanami" : "hanami-#{name}"

          %(gem "#{gem_name}", #{hanami_gem_version(name)})
        end

        # @since 2.0.0
        # @api private
        def hanami_gem_version(name)
          gem_name = name == "hanami" ? "hanami" : "hanami-#{name}"

          if hanami_head?
            %(github: "hanami/#{gem_name}", branch: "main")
          else
            %("#{Version.gem_requirement}")
          end
        end

        # @since 2.1.0
        # @api private
        def hanami_assets_npm_package
          if hanami_head?
            %("hanami-assets": "hanami/assets-js#main")
          else
            %("hanami-assets": "#{Version.npm_package_requirement}")
          end
        end

        # @since 2.0.0
        # @api private
        def camelized_app_name
          inflector.camelize(app).gsub(/[^\p{Alnum}]/, "")
        end

        # @since 2.0.0
        # @api private
        def underscored_app_name
          inflector.underscore(app)
        end

        # @since 2.1.0
        # @api private
        def humanized_app_name
          inflector.humanize(app)
        end

        # @since 2.1.0
        # @api private
        def hanami_head?
          options.fetch(:head)
        end

        # @since 2.3.0
        # @api private
        def gem_source
          value = options.fetch(:gem_source)
          return value if value.match? %r{\A\w+://}

          "https://#{value}"
        end

        # @since 2.1.0
        # @api private
        def generate_assets?
          !options.fetch(:skip_assets, false)
        end

        # @since 2.2.0
        # @api private
        def generate_db?
          !options.fetch(:skip_db, false)
        end

        # @since 2.2.0
        # @api private
        def generate_view?
          !options.fetch(:skip_view, false)
        end

        # @since 2.2.0
        # @api private
        def generate_sqlite?
          generate_db? && database_option == Commands::Gem::New::DATABASE_SQLITE
        end

        # @since 2.2.0
        # @api private
        def generate_postgres?
          generate_db? && database_option == Commands::Gem::New::DATABASE_POSTGRES
        end

        # @since 2.2.0
        # @api private
        def generate_mysql?
          generate_db? && database_option == Commands::Gem::New::DATABASE_MYSQL
        end

        # @since 2.2.0
        # @api private
        def database_url
          if generate_sqlite?
            "sqlite://db/#{app}.sqlite"
          elsif generate_postgres?
            "postgres://localhost/#{app}"
          elsif generate_mysql?
            "mysql2://root@localhost/#{app}"
          else
            raise "Unknown database option: #{database_option}"
          end
        end

        # @since 2.1.0
        # @api private
        def bundled_views?
          Hanami.bundled?("hanami-view")
        end

        # @since 2.1.0
        # @api private
        def bundled_assets?
          Hanami.bundled?("hanami-assets")
        end

        # @since 2.2.0
        # @api private
        def bundled_dry_monads?
          Hanami.bundled?("dry-monads")
        end

        # @since 2.1.0
        # @api private
        #
        # @see https://rubyreferences.github.io/rubychanges/3.1.html#values-in-hash-literals-and-keyword-arguments-can-be-omitted
        def ruby_omit_hash_values?
          RUBY_VERSION >= "3.1"
        end

        private

        def database_option
          options.fetch(:database, Commands::Gem::New::DATABASE_SQLITE)
        end

        # @since 2.0.0
        # @api private
        attr_reader :inflector

        # @since 2.0.0
        # @api private
        attr_reader :app

        # @since 2.1.0
        # @api private
        attr_reader :options
      end
    end
  end
end
