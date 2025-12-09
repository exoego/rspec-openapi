# frozen_string_literal: true

require_relative "../../app/command"
require_relative "structure/dump"

module Hanami
  module CLI
    module Commands
      module App
        module DB
          class Rollback < DB::Command
            desc "Rollback database to a previous migration"

            argument :steps, desc: "Number of migrations to rollback", required: false
            option :target, desc: "Target migration number", aliases: ["-t"]
            option :dump, desc: "Dump structure after rolling back", default: true
            option :gateway, required: false, desc: "Use database for gateway"

            def call(
              steps: nil,
              app: false,
              slice: nil,
              gateway: nil,
              target: nil,
              dump: true,
              command_exit: method(:exit),
              **
            )
              # We allow either a number of steps or a target migration number to be provided
              # If steps is provided and target is not, we use steps as the target migration number, but we also have to
              # make sure steps is a number, hence some additional logic around checking and converting to number
              target = steps if steps && !target && !code_is_number?(steps)
              steps_count = steps && code_is_number?(steps) ? Integer(steps) : 1

              database = resolve_target_database(app: app, slice: slice, gateway: gateway, command_exit: command_exit)
              return unless database

              migration_code, migration_name = find_migration_target(target, steps_count, database)

              if migration_name.nil?
                output = if steps && code_is_number?(steps)
                           "==> migration file for #{steps} steps back was not found"
                         elsif target
                           "==> migration file for target #{target} was not found"
                         else
                           "==> no migrations to rollback"
                         end

                out.puts output
                return
              end

              measure "database #{database.name} rolled back to #{migration_name}" do
                database.run_migrations(target: Integer(migration_code))
                true
              end

              if dump && !re_running_in_test?
                run_command(
                  Structure::Dump,
                  app: database.slice == self.app,
                  slice: database.slice == self.app ? nil : database.slice.slice_name.to_s,
                  gateway: database.gateway_name == :default ? nil : database.gateway_name.to_s,
                  command_exit: command_exit
                )
              end

              re_run_development_command_in_test
            end

            private

            def resolve_target_database(app:, slice:, gateway:, command_exit:)
              if gateway && !app && !slice
                err.puts "When specifying --gateway, an --app or --slice must also be given"
                command_exit.(1)
                return
              end

              if slice
                resolve_slice_database(slice, gateway, command_exit)
              elsif app
                resolve_app_database(gateway, command_exit)
              else
                resolve_default_database(command_exit)
              end
            end

            def resolve_slice_database(slice_name, gateway, command_exit)
              slice = resolve_slice(slice_name, command_exit)
              return unless slice

              databases = build_databases(slice)

              if gateway
                database = databases[gateway.to_sym]
                unless database
                  err.puts %(No gateway "#{gateway}" found in slice "#{slice_name}")
                  command_exit.(1)
                  return
                end
                database
              elsif databases.size == 1
                databases.values.first
              else
                err.puts "Multiple gateways found in slice #{slice_name}. Please specify --gateway option."
                command_exit.(1)
              end
            end

            def resolve_app_database(gateway, command_exit)
              databases = build_databases(app)

              if gateway
                database = databases[gateway.to_sym]
                unless database
                  err.puts %(No gateway "#{gateway}" found in app)
                  command_exit.(1)
                  return
                end
                database
              elsif databases.size == 1
                databases.values.first
              else
                err.puts "Multiple gateways found in app. Please specify --gateway option."
                command_exit.(1)
              end
            end

            def resolve_default_database(command_exit)
              all_dbs = all_databases

              if all_dbs.empty?
                err.puts "No databases found"
                command_exit.(1)
              elsif all_dbs.size == 1
                all_dbs.first
              else
                app_databases = build_databases(app)
                if app_databases.size == 1
                  app_databases.values.first
                elsif app_databases.size > 1
                  err.puts "Multiple gateways found in app. Please specify --gateway option."
                  command_exit.(1)
                  return
                else
                  err.puts "Multiple database contexts found. Please specify --app or --slice option."
                  command_exit.(1)
                  return
                end
              end
            end

            def resolve_slice(slice_name, command_exit)
              slice_name_sym = inflector.underscore(Shellwords.shellescape(slice_name)).to_sym
              slice = app.slices[slice_name_sym]

              unless slice
                err.puts %(Slice "#{slice_name}" not found)
                command_exit.(1)
                return
              end

              ensure_database_slice(slice)
              slice
            end

            def find_migration_target(target, steps_count, database)
              applied_migrations = database.applied_migrations

              return if applied_migrations.empty?

              if applied_migrations.one? && target.nil?
                return initial_state(applied_migrations)
              end

              if target
                migration = applied_migrations.detect { |m| m.split("_").first == target }
                migration_code = migration&.split("_")&.first
                migration_name = migration ? File.basename(migration, ".*") : nil
              else
                # When rolling back N steps, we want to target the migration that is N steps back
                # If we have migrations [A, B, C, D] and want to rollback 2 steps from D,
                # we want to target B (index -3, since we go back 2 steps + 1 for the target)
                target_index = -(steps_count + 1)

                if target_index.abs > applied_migrations.size
                  return initial_state(applied_migrations)
                else
                  migration = applied_migrations[target_index]
                  migration_code = migration&.split("_")&.first
                  migration_name = migration ? File.basename(migration, ".*") : nil
                end
              end

              [migration_code, migration_name]
            end

            def initial_state(applied_migrations)
              migration = applied_migrations.first

              migration_code = Integer(migration.split("_").first) - 1
              migration_name = "initial state"

              [migration_code, migration_name]
            end

            def code_is_number?(code)
              code&.to_s&.match?(/^\d+$/) && !code.to_s.match?(/^\d{10,}$/)
            end
          end
        end
      end
    end
  end
end
