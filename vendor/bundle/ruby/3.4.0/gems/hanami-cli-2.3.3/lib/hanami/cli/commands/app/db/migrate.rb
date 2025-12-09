# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # @api private
          class Migrate < DB::Command
            desc "Migrates database"

            option :gateway, required: false, desc: "Use database for gateway"
            option :target, desc: "Target migration number", aliases: ["-t"]
            option :dump,
                   required: false,
                   type: :boolean,
                   default: true,
                   desc: "Dump the database structure after migrating"

            def call(target: nil, app: false, slice: nil, gateway: nil, dump: true, command_exit: method(:exit), **)
              databases(app: app, slice: slice, gateway: gateway).each do |database|
                if migrations_dir_missing?(database)
                  warn_on_missing_migrations_dir(database)
                elsif no_migrations?(database)
                  warn_on_empty_migrations_dir(database)
                else
                  migrate_database(database, target: target)
                end
              end

              # Only dump for the initial command, not a re-run of the command in test env
              if dump && !re_running_in_test?
                run_command(
                  Structure::Dump,
                  app: app, slice: slice, gateway: gateway,
                  command_exit: command_exit
                )
              end

              re_run_development_command_in_test
            end

            private

            def migrate_database(database, target:)
              return true unless database.migrations_dir?

              measure "database #{database.name} migrated" do
                if target
                  database.run_migrations(target: Integer(target))
                else
                  database.run_migrations
                end

                true
              end
            end

            def migrations_dir_missing?(database)
              !database.migrations_dir?
            end

            def no_migrations?(database)
              database.sequel_migrator.files.empty?
            end

            def warn_on_missing_migrations_dir(database)
              out.puts <<~STR
                WARNING: Database #{database.name} expects migrations to be located within #{relative_migrations_path(database)} but that folder does not exist.

                No database migrations can be run for this database.
              STR
            end

            def warn_on_empty_migrations_dir(database)
              out.puts <<~STR
                NOTE: Empty database migrations folder (#{relative_migrations_path(database)}) for #{database.name}
              STR
            end

            def relative_migrations_path(database)
              database
                .migrations_path
                .relative_path_from(database.slice.app.root)
                .to_s + "/"
            end
          end
        end
      end
    end
  end
end
