# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # @api private
          class Prepare < DB::Command
            desc "Prepare databases"

            def call(app: false, slice: nil, **)
              command_exit = -> code { throw :command_exited, code }
              command_exit_arg = {command_exit: command_exit}

              # Since any slice may have multiple databases, we need to run the steps below in a
              # particular order to satisfy our ROM/Sequel's migrator, which requires _all_ the
              # databases in a slice to be created before we can use it.
              #
              # So before we do anything else, make sure to create/load every database first.
              databases(app: app, slice: slice).each do |database|
                command_args = {
                  **command_exit_arg,
                  app: database.slice.app?,
                  slice: database.slice,
                  gateway: database.gateway_name.to_s
                }

                exit_code = catch :command_exited do
                  unless database.exists?
                    run_command(DB::Create, **command_args)
                    run_command(DB::Structure::Load, **command_args)
                  end

                  nil
                end

                return exit exit_code if exit_code.to_i > 1
              end

              # Once all databases are created, the migrator will properly load for each slice, and
              # we can migrate each database.
              databases(app: app, slice: slice).each do |database|
                command_args = {
                  **command_exit_arg,
                  app: database.slice.app?,
                  slice: database.slice,
                  gateway: database.gateway_name.to_s
                }

                exit_code = catch :command_exited do
                  run_command(DB::Migrate, **command_args)

                  nil
                end

                return exit exit_code if exit_code.to_i > 1
              end

              # Finally, load the seeds for the slice overall, which is a once-per-slice operation.
              run_command(DB::Seed, app: app, slice: slice) unless re_running_in_test?

              re_run_development_command_in_test
            end
          end
        end
      end
    end
  end
end
