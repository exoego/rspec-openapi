# frozen_string_literal: true

require_relative "command"

module Hanami
  module CLI
    module Commands
      module App
        module Assets
          # Watches for asset changes within each slice.
          #
          # @since 2.1.0
          # @api private
          class Watch < Assets::Command
            desc "Start assets watch mode"

            private

            # @since 2.1.0
            # @api private
            def assets_command(slice)
              super + ["--watch"]
            end
          end
        end
      end
    end
  end
end
