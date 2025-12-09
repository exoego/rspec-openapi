# frozen_string_literal: true

require_relative "../../interactive_system_call"

module Hanami
  module CLI
    module Commands
      module App
        # @since 2.1.0
        # @api private
        class Dev < App::Command
          # @since 2.1.0
          # @api private
          desc "Start the application in development mode"

          # @since 2.1.0
          # @api private
          def initialize(
            out:, err:,
            system_call: InteractiveSystemCall.new(out: out, err: err),
            **opts
          )
            super(out: out, err: err, **opts)

            @system_call = system_call
          end

          # @since 2.1.0
          # @api private
          def call(**)
            bin, args = executable
            system_call.call(bin, *args)
          end

          private

          # @since 2.1.0
          # @api private
          attr_reader :system_call

          # @since 2.1.0
          # @api private
          def executable
            [::File.join("bin", "dev")]
          end
        end
      end
    end
  end
end
