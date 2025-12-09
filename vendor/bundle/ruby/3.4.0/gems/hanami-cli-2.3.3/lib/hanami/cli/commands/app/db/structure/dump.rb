# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # @api private
          module Structure
            # @api private
            class Dump < DB::Command
              desc "Dumps database structure to config/db/structure.sql file"

              option :gateway, required: false, desc: "Use database for gateway"

              # @api private
              def call(app: false, slice: nil, gateway: nil, command_exit: method(:exit), **)
                exit_codes = []

                databases(app: app, slice: slice, gateway: gateway).each do |database|
                  relative_structure_path = database.structure_file
                    .relative_path_from(database.slice.app.root)

                  measure("#{database.name} structure dumped to #{relative_structure_path}") do
                    catch :dump_failed do
                      result = database.structure_sql_dump
                      exit_codes << result.exit_code if result.respond_to?(:exit_code)

                      unless result.successful?
                        out.puts result.err
                        throw :dump_failed, false
                      end

                      structure_sql = result.sql

                      migrations_sql = database.schema_migrations_sql_dump

                      File.open(database.structure_file, "w") do |f|
                        f.puts "#{structure_sql}\n"
                        if migrations_sql
                          f.puts "#{migrations_sql}\n"
                        end
                      end

                      true
                    end
                  end
                end

                exit_codes.each do |code|
                  break command_exit.(code) if code > 0
                end
              end
            end
          end
        end
      end
    end
  end
end
