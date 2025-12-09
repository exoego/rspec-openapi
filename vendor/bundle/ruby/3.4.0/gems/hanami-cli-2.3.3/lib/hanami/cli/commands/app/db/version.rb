# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module DB
          # @api private
          class Version < DB::Command
            desc "Print schema version"

            option :gateway, required: false, desc: "Use database for gateway"

            # rubocop:disable Layout/LineLength
            # @api private
            def call(app: false, slice: nil, gateway: nil, **)
              databases(app: app, slice: slice, gateway: gateway).each do |database|
                unless database.migrations_dir?
                  relative_migrations_path = database.migrations_path.relative_path_from(database.slice.app.root)
                  out.puts "=> Cannot find version for database #{database.name}: no migrations directory at #{relative_migrations_path}/"
                  return
                end

                migration = database.applied_migrations.last
                version = migration ? File.basename(migration, ".*") : "not available"

                out.puts "=> #{database.name} current schema version is #{version}"
              end
              # rubocop:enable Layout/LineLength
            end
          end
        end
      end
    end
  end
end
