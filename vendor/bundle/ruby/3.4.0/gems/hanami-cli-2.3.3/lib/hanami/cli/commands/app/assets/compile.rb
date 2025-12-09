# frozen_string_literal: true

require_relative "command"

module Hanami
  module CLI
    module Commands
      module App
        module Assets
          # Compiles assets for each slice.
          #
          # @since 2.1.0
          # @api private
          class Compile < Assets::Command
            desc "Compile assets for deployments"

            private

            # @since 2.1.0
            # @api private
            def assets_command(slice)
              cmd = super

              if config.subresource_integrity.any?
                cmd << "--sri=#{escape(config.subresource_integrity.join(','))}"
              end

              cmd
            end
          end
        end
      end
    end
  end
end
