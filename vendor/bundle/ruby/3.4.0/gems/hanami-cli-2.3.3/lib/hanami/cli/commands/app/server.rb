# frozen_string_literal: true

require "hanami/port"
require_relative "../app"
require_relative "../../server"

module Hanami
  module CLI
    module Commands
      module App
        # Launch Hanami web server.
        #
        # It's intended to be used only on development. For production, you
        # should use the rack handler command directly (i.e. `bundle exec puma
        # -C config/puma.rb`).
        #
        # The server is just a thin wrapper on top of Rack::Server. The options that it
        # accepts fall into two different categories:
        #
        # - When not explicitly set, port and host are not passed to the rack
        # server instance. This way, they can be configured through the
        # configured rack handler (e.g., the puma configuration file).
        #
        # - All others are always given by the Hanami command.
        #
        # Run `bundle exec hanami server -h` to see all the supported options.
        #
        # @since 2.0.0
        # @api private
        class Server < Command
          # @since 2.0.0
          # @api private
          DEFAULT_CONFIG_PATH = "config.ru"
          private_constant :DEFAULT_CONFIG_PATH

          desc "Start Hanami app server"

          option :host, default: nil, required: false,
                        desc: "The host address to bind to (falls back to the rack handler)"
          option :port, default: Hanami::Port::DEFAULT, required: false,
                        desc: "The port to run the server on (falls back to the rack handler)"
          option :config, default: DEFAULT_CONFIG_PATH, required: false, desc: "Rack configuration file"
          option :debug, default: false, required: false, desc: "Turn on/off debug output", type: :flag
          option :warn, default: false, required: false, desc: "Turn on/off warnings", type: :flag

          # @since 2.0.0
          # @api private
          def initialize(server: Hanami::CLI::Server.new, **opts)
            super(**opts)
            @server = server
          end

          # @since 2.0.0
          # @api private
          def call(port: Hanami::Port::DEFAULT, **kwargs)
            server.call(port: Hanami::Port[port], **kwargs)
          end

          private

          attr_reader :server
        end
      end
    end
  end
end
