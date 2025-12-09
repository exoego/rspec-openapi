# frozen_string_literal: true

require_relative "../../system_call"

module Hanami
  module CLI
    module Commands
      module App
        # The `install` command exists to provide third parties a hook for their own installation
        # behaviour to be run as part of `hanami new`.
        #
        # Third parties should register their install commands like so:
        #
        # ```
        # if Hanami::CLI.within_hanami_app?
        #   Hanami::CLI.after "install", MyHanamiGem::CLI::Commands::Install
        # end
        # ````
        #
        # @since 2.0.0
        # @api private
        class Install < Command
          # @since 2.1.0
          # @api private
          DEFAULT_HEAD = false
          private_constant :DEFAULT_HEAD

          # @since 2.1.0
          # @api private
          desc "Install Hanami third-party plugins"

          # @since 2.1.0
          # @api private
          option :head, type: :flag, desc: "Install head deps", default: DEFAULT_HEAD

          # @api private
          private attr_reader :bundler

          def initialize(
            fs:,
            bundler: CLI::Bundler.new(fs: fs),
            **opts
          )
            @bundler = bundler
          end

          # @since 2.0.0
          # @api private
          def call(head: DEFAULT_HEAD, **)
            bundler.install!
          end
        end
      end
    end
  end
end
