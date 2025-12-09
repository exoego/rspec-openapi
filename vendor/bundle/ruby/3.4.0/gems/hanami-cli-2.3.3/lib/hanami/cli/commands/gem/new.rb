# frozen_string_literal: true

require "dry/inflector"
require_relative "../../errors"

module Hanami
  module CLI
    module Commands
      module Gem
        # @since 2.0.0
        # @api private
        class New < Command
          # @since 2.1.0
          # @api private
          HEAD_DEFAULT = false
          private_constant :HEAD_DEFAULT

          # @since 2.3.0
          # @api private
          GEM_SOURCE_DEFAULT = "rubygems.org"
          private_constant :GEM_SOURCE_DEFAULT

          # @since 2.0.0
          # @api private
          SKIP_INSTALL_DEFAULT = false
          private_constant :SKIP_INSTALL_DEFAULT

          # @since 2.1.0
          # @api private
          SKIP_ASSETS_DEFAULT = false
          private_constant :SKIP_ASSETS_DEFAULT

          # @since 2.2.0
          # @api private
          SKIP_DB_DEFAULT = false
          private_constant :SKIP_DB_DEFAULT

          # @since 2.2.0
          # @api private
          SKIP_VIEW_DEFAULT = false
          private_constant :SKIP_VIEW_DEFAULT

          # @since 2.2.0
          # @api private
          DATABASE_SQLITE = "sqlite"

          # @since 2.2.0
          # @api private
          DATABASE_POSTGRES = "postgres"

          # @since 2.2.0
          # @api private
          DATABASE_MYSQL = "mysql"

          # @since 2.2.0
          # @api private
          SUPPORTED_DATABASES = [DATABASE_SQLITE, DATABASE_POSTGRES, DATABASE_MYSQL].freeze

          # @api private
          FORBIDDEN_APP_NAMES = %w[app slice].freeze

          desc "Generate a new Hanami app"

          # @since 2.0.0
          # @api private
          argument :app, required: true, desc: "App name"

          # @since 2.1.0
          # @api private
          option :head, type: :flag, required: false,
                        default: HEAD_DEFAULT,
                        desc: "Use Hanami HEAD version (from GitHub `main` branches)"

          # @since 2.3.0
          # @api private
          option :gem_source, required: true,
                              default: GEM_SOURCE_DEFAULT,
                              desc: "Where to source Ruby gems from"

          # @since 2.0.0
          # @api private
          option :skip_install, type: :flag, required: false,
                                default: SKIP_INSTALL_DEFAULT,
                                desc: "Skip app installation (Bundler, third-party Hanami plugins)"

          # @since 2.1.0
          # @api private
          option :skip_assets, type: :flag, required: false,
                               default: SKIP_ASSETS_DEFAULT,
                               desc: "Skip including hanami-assets"

          # @since 2.2.0
          # @api private
          option :skip_db, type: :flag, required: false,
                           default: SKIP_DB_DEFAULT,
                           desc: "Skip including hanami-db"

          # @since 2.2.0
          # @api private
          option :skip_view, type: :flag, required: false,
                             default: SKIP_VIEW_DEFAULT,
                             desc: "Skip including hanami-view"

          # @since 2.2.0
          # @api private
          option :database, type: :string, required: false,
                            default: DATABASE_SQLITE,
                            desc: "Database adapter (supported: sqlite, mysql, postgres)"

          # rubocop:disable Layout/LineLength
          example [
            "bookshelf                                    # Generate a new Hanami app in `bookshelf/' directory, using `Bookshelf' namespace",
            "bookshelf --head                             # Generate a new Hanami app, using Hanami HEAD version from GitHub `main' branches",
            "bookshelf --gem-source=gem.coop              # Generate a new Hanami app, using https://gem.coop as Ruby gem source",
            "bookshelf --skip-install                     # Generate a new Hanami app, but it skips Hanami installation",
            "bookshelf --skip-assets                      # Generate a new Hanami app without hanami-assets",
            "bookshelf --skip-db                          # Generate a new Hanami app without hanami-db",
            "bookshelf --skip-view                        # Generate a new Hanami app without hanami-view",
            "bookshelf --database={sqlite|postgres|mysql} # Generate a new Hanami app with a specified database (default: sqlite)",
          ]
          # rubocop:enable Layout/LineLength

          # rubocop:disable Metrics/ParameterLists

          # @since 2.0.0
          # @api private
          def initialize(
            fs:,
            bundler: CLI::Bundler.new(fs: fs),
            generator: Generators::Gem::App.new(fs: fs, inflector: inflector),
            system_call: SystemCall.new,
            **opts
          )
            super(fs: fs, **opts)
            @bundler = bundler
            @generator = generator
            @system_call = system_call
          end

          # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity

          # @since 2.0.0
          # @api private
          def call(
            app:,
            head: HEAD_DEFAULT,
            gem_source: GEM_SOURCE_DEFAULT,
            skip_install: SKIP_INSTALL_DEFAULT,
            skip_assets: SKIP_ASSETS_DEFAULT,
            skip_db: SKIP_DB_DEFAULT,
            skip_view: SKIP_VIEW_DEFAULT,
            database: nil
          )
            # rubocop:enable Metrics/ParameterLists
            app = inflector.underscore(app)

            raise PathAlreadyExistsError.new(app) if fs.exist?(app)
            raise ForbiddenAppNameError.new(app) if FORBIDDEN_APP_NAMES.include?(app)

            normalized_database ||= normalize_database(database)

            fs.mkdir(app)
            fs.chdir(app) do
              context = Generators::Context.new(
                inflector,
                app,
                head: head,
                gem_source: gem_source,
                skip_assets: skip_assets,
                skip_db: skip_db,
                skip_view: skip_view,
                database: normalized_database
              )
              generator.call(app, context: context) do
                if skip_install
                  out.puts "Skipping installation, please enter `#{app}' directory and run `bundle exec hanami install'"
                else
                  out.puts "Running bundle install..."
                  bundler.install!

                  unless skip_assets
                    out.puts "Running npm install..."
                    system_call.call("npm", ["install"]).tap do |result|
                      unless result.successful?
                        puts "NPM ERROR:"
                        puts(result.err.lines.map { |line| line.prepend("    ") })
                      end
                    end
                  end

                  out.puts "Running hanami install..."
                  run_install_command!(head: head)

                  out.puts "Running bundle binstubs hanami-cli rake..."
                  install_binstubs!

                  out.puts "Initializing git repository..."
                  init_git_repository
                end
              end
            end
          end
          # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

          private

          attr_reader :bundler
          attr_reader :generator
          attr_reader :system_call

          def normalize_database(database)
            case database
            when nil, "sqlite", "sqlite3"
              DATABASE_SQLITE
            when "mysql", "mysql2"
              DATABASE_MYSQL
            when "postgres", "postgresql", "pg"
              DATABASE_POSTGRES
            else
              raise DatabaseNotSupportedError.new(database, SUPPORTED_DATABASES)
            end
          end

          def run_install_command!(head:)
            head_flag = head ? " --head" : ""
            bundler.exec("hanami install#{head_flag}").tap do |result|
              if result.successful?
                bundler.exec("check").successful? || bundler.exec("install")
              else
                raise HanamiInstallError.new(result.err)
              end
            end
          end

          # @api private
          def install_binstubs!
            bundler.bundle("binstubs hanami-cli rake")
          end

          # @api private
          def init_git_repository
            system_call.call("git", ["init"]).tap do |result|
              unless result.successful?
                out.puts "WARNING: Failed to initialize git repository"
                out.puts(result.err.lines.map { |line| line.prepend("    ") })
              end
            end
          end
        end
      end
    end
  end
end
