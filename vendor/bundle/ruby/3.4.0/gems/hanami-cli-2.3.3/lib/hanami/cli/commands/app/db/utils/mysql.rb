# frozen_string_literal: true

require_relative "database"

module Hanami
  module CLI
    module Commands
      module App
        module DB
          module Utils
            # @api private
            class Mysql < Database
              # @api private
              def exec_create_command
                return true if exists?

                exec_cli("mysql", %(-e "CREATE DATABASE #{escaped_name}"))
              end

              # @api private
              # @since 2.2.0
              def exec_drop_command
                return true unless exists?

                exec_cli("mysql", %(-e "DROP DATABASE #{escaped_name}"))
              end

              # @api private
              # @since 2.2.0
              def exists?
                result = exec_cli("mysql", %(-e "SHOW DATABASES LIKE '#{name}'" --batch))
                raise Hanami::CLI::DatabaseExistenceCheckError.new(result.err) unless result.successful?

                result.out != ""
              end

              # @api private
              # @since 2.2.0
              def exec_dump_command
                exec_cli(
                  "mysqldump",
                  "--no-data --routines --skip-comments --set-gtid-purged=off #{escaped_name}"
                )
              end

              # rubocop:disable Layout/LineLength
              # @api private
              # @since 2.2.0
              def exec_load_command
                exec_cli(
                  "mysql",
                  %(--commands --execute "SET FOREIGN_KEY_CHECKS = 0; SOURCE #{structure_file}; SET FOREIGN_KEY_CHECKS = 1" --database #{escaped_name})
                )
              end
              # rubocop:enable Layout/LineLength

              private

              def escaped_name
                Shellwords.escape(name)
              end

              def exec_cli(cli_name, cli_args)
                system_call.call(
                  "#{cli_name} #{cli_options} #{cli_args}",
                  env: cli_env_vars
                )
              end

              def cli_options
                [].tap { |opts|
                  opts << "--host=#{Shellwords.escape(database_uri.host)}" if database_uri.host
                  opts << "--port=#{Shellwords.escape(database_uri.port)}" if database_uri.port
                  opts << "--user=#{Shellwords.escape(database_uri.user)}" if database_uri.user
                }.join(" ")
              end

              def cli_env_vars
                @cli_env_vars ||= {}.tap do |vars|
                  vars["MYSQL_PWD"] = database_uri.password.to_s if database_uri.password
                end
              end
            end
          end
        end
      end
    end
  end
end
