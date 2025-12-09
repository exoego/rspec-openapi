# frozen_string_literal: true

begin
  require "rackup"
rescue LoadError
  # Rack 2 doesn't have rackup gem, use Rack::Server instead
end

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    class Server
      # @since 2.0.0
      # @api private
      attr_reader :rack_server

      # @since 2.0.0
      # @api private
      RACK_FALLBACK_OPTIONS = {
        host: :Host,
        port: :Port
      }.freeze

      # @since 2.0.0
      # @api private
      OVERRIDING_OPTIONS = {
        config: :config,
        debug: :debug,
        warn: :warn
      }.freeze

      def self.rack_server_class
        if defined?(Rackup::Server)
          Rackup::Server
        else
          Rack::Server
        end
      end

      # @since 2.0.0
      # @api private
      def initialize(rack_server: self.class.rack_server_class)
        @rack_server = rack_server
      end

      # @since 2.0.0
      # @api private
      def call(**options)
        rack_server.start(Hash[
          extract_rack_fallback_options(options) + extract_overriding_options(options)
        ])
      end

      private

      def extract_rack_fallback_options(options)
        RACK_FALLBACK_OPTIONS.filter_map do |(name, rack_name)|
          options[name] && [rack_name, options[name]]
        end
      end

      def extract_overriding_options(options)
        OVERRIDING_OPTIONS.map do |(name, rack_name)|
          [rack_name, options[name]]
        end
      end
    end
  end
end
