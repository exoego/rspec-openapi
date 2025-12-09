# frozen_string_literal: true

require "shellwords"
require_relative "utils/database"

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # Base class for `hanami` CLI commands intended to be executed within an existing Hanami
          # app.
          #
          # @since 2.2.0
          # @api private
          class Command < App::Command
            option :app, required: false, type: :flag, default: false, desc: "Use app database"
            option :slice, required: false, desc: "Use database for slice"

            # @api private
            attr_reader :system_call

            # @api private
            attr_reader :test_env_executor

            def initialize(
              out:, err:,
              system_call: SystemCall.new,
              test_env_executor: InteractiveSystemCall.new(out: out, err: err),
              nested_command: false,
              **opts
            )
              super(out: out, err: err, **opts)
              @system_call = system_call
              @test_env_executor = test_env_executor
              @nested_command = nested_command
            end

            def run_command(klass, ...)
              klass.new(
                out: out,
                fs: fs,
                system_call: system_call,
                test_env_executor: test_env_executor,
                nested_command: true,
              ).call(...)
            end

            def nested_command?
              @nested_command
            end

            private

            def databases(app: false, slice: nil, gateway: nil)
              if gateway && !app && !slice
                err.puts "When specifying --gateway, an --app or --slice must also be given"
                exit 1
              end

              databases =
                if slice
                  [database_for_slice(slice, gateway: gateway)]
                elsif app
                  [database_for_slice(self.app, gateway: gateway)]
                else
                  all_databases
                end

              databases.flatten
            end

            def database_for_slice(slice, gateway: nil)
              unless slice.is_a?(Class) && slice < Hanami::Slice
                slice_name = inflector.underscore(Shellwords.shellescape(slice)).to_sym
                slice = app.slices[slice_name]
              end

              ensure_database_slice slice

              databases = build_databases(slice)

              if gateway
                databases.fetch(gateway.to_sym) do
                  err.puts %(No gateway "#{gateway}" in #{slice})
                  exit 1
                end
              else
                databases.values
              end
            end

            def all_databases # rubocop:disable Metrics/AbcSize
              slices = [app] + app.slices.with_nested

              slice_gateways_by_database_url = slices.each_with_object({}) { |slice, hsh|
                db_provider_source = slice.container.providers[:db]&.source
                next unless db_provider_source

                db_provider_source.database_urls.each do |gateway, url|
                  hsh[url] ||= []
                  hsh[url] << {slice: slice, gateway: gateway}
                end
              }

              slice_gateways_by_database_url.each_with_object([]) { |(url, slice_gateways), arr|
                slice_gateways_with_config = slice_gateways.select {
                  migrate_dir = _1[:gateway] == :default ? "migrate" : "#{_1[:gateway]}_migrate"

                  _1[:slice].root.join("config", "db", migrate_dir).directory?
                }

                db_slice_gateway = slice_gateways_with_config.first || slice_gateways.first
                database = Utils::Database.database_class(url).new(
                  slice: db_slice_gateway.fetch(:slice),
                  gateway_name: db_slice_gateway.fetch(:gateway),
                  system_call: system_call
                )

                warn_on_misconfigured_database database, slice_gateways_with_config.map { _1.fetch(:slice) }

                arr << database
              }
            end

            def build_databases(slice)
              Utils::Database.from_slice(slice: slice, system_call: system_call)
            end

            def ensure_database_slice(slice)
              return if slice.container.providers[:db]

              out.puts "#{slice} does not have a :db provider."
              exit 1
            end

            def warn_on_misconfigured_database(database, slices) # rubocop:disable Metrics/AbcSize
              if slices.length > 1
                out.puts <<~STR
                  WARNING: Database #{database.name} is configured for multiple config/db/ directories:

                  #{slices.map { "- " + _1.root.relative_path_from(_1.app.root).join("config", "db").to_s }.join("\n")}

                  Using config in #{database.slice.slice_name.to_s.inspect} slice only.

                STR
              elsif !database.db_config_dir?
                relative_path = database.slice.root
                  .relative_path_from(database.slice.app.root)
                  .join("config", "db").to_s

                out.puts <<~STR
                  WARNING: Database #{database.name} expects the folder #{relative_path}/ to exist but it does not.

                STR
              end
            end

            # Invokes the currently executing `hanami` CLI command again, but with any `--env` args
            # removed and the `HANAMI_ENV=test` env var set.
            #
            # This is called by certain `db` commands only, and runs only if the Hanami env is
            # `:development`. This behavior important to streamline the local development
            # experience, making sure that the test databases are kept in sync with operations run
            # on the development databases.
            #
            # Spawning an entirely new process to change the env is a compromise approach until we
            # can have an API for reinitializing the DB subsystem in-process with a different env.
            def re_run_development_command_in_test
              # Only invoke a new process if we've been called as `hanami`. This avoids awkward
              # failures when testing commands via RSpec, for which the $0 is "/full/path/to/rspec".
              return unless $0.end_with?("hanami")

              # If this special env key is set, then a re-run has already been invoked. This would
              # mean the current command is actually a nested command run by another db command. In
              # this case, don't trigger a re-runs, because one is already in process.
              return if nested_command?

              # Re-runs in test are for development-env commands only.
              return unless Hanami.env == :development

              cmd = $0
              cmd = "bundle exec #{cmd}" if ENV.key?("BUNDLE_BIN_PATH")

              test_env_executor.call(
                cmd, *argv_without_env_args,
                env: {
                  "HANAMI_ENV" => "test",
                  "HANAMI_CLI_DB_COMMAND_RE_RUN_IN_TEST" => "true"
                }
              )
            end

            def re_running_in_test?
              ENV.key?("HANAMI_CLI_DB_COMMAND_RE_RUN_IN_TEST")
            end

            # Returns the `ARGV` with every option argument included, but the `-e` or `--env` args
            # removed.
            def argv_without_env_args
              new_argv = ARGV.dup

              env_arg_index = new_argv.index {
                _1 == "-e" || _1 == "--env" || _1.start_with?("-e=") || _1.start_with?("--env=")
              }

              if env_arg_index
                # Remove the env argument
                env_arg = new_argv.delete_at(env_arg_index)

                # If the env argument is not in combined form ("--env foo" rather than "--env=foo"),
                # then remove the following argument too
                new_argv.delete_at(env_arg_index) if ["-e", "--env"].include?(env_arg)
              end

              new_argv
            end
          end
        end
      end
    end
  end
end
