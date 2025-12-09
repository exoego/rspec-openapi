# frozen_string_literal: true

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.2.0
        # @api private
        class Migration
          # @since 2.2.0
          # @api private
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
          end

          # @since 2.2.0
          # @api private
          def call(key:, base_path:, gateway: nil, **_opts)
            name = inflector.underscore(key)
            ensure_valid_name(name)

            base_path = nil if base_path == "app" # Migrations are in the root dir, not app/
            migrate_dir = gateway ? "#{gateway}_migrate" : "migrate"

            path = fs.join(*[base_path, "config", "db", migrate_dir, file_name(name)].compact)

            fs.create(path, FILE_CONTENTS)
          end

          private

          attr_reader :fs, :inflector, :out

          VALID_NAME_REGEX = /^[_a-z0-9]+$/
          private_constant :VALID_NAME_REGEX

          def ensure_valid_name(name)
            unless VALID_NAME_REGEX.match?(name.downcase)
              raise InvalidMigrationNameError.new(name)
            end
          end

          def file_name(name)
            "#{Time.now.strftime(VERSION_FORMAT)}_#{name}.rb"
          end

          VERSION_FORMAT = "%Y%m%d%H%M%S"
          private_constant :VERSION_FORMAT

          FILE_CONTENTS = <<~RUBY
            # frozen_string_literal: true

            ROM::SQL.migration do
              # Add your migration here.
              #
              # See https://guides.hanamirb.org/v2.2/database/migrations/ for details.
              change do
              end
            end
          RUBY
          private_constant :FILE_CONTENTS
        end
      end
    end
  end
end
