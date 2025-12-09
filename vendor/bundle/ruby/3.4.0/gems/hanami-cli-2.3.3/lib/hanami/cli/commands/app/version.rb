# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        # @since 2.0.0
        # @api private
        class Version < Command
          desc "Print Hanami app version"

          # @since 2.0.0
          # @api private
          def call(*)
            require "hanami/version"
            out.puts "v#{Hanami::VERSION}"
          end
        end
      end
    end
  end
end
