# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module Gem
        # @since 2.0.0
        # @api private
        class Version < Command
          desc "Hanami version"

          # @since 2.0.0
          # @api private
          def call(*)
            version = detect_version
            out.puts "v#{version}"
          end

          private

          def detect_version
            hanami_version ||
              hanami_cli_version
          end

          def hanami_version
            require "hanami/version"

            Hanami::VERSION
          rescue LoadError # rubocop:disable Lint/SuppressedException
          end

          def hanami_cli_version
            require "hanami/cli/version"

            Hanami::CLI::VERSION
          end
        end
      end
    end
  end
end
