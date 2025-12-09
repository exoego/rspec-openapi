# frozen_string_literal: true

require "hanami/router/params"
require "hanami/middleware/error"
require_relative "../router/constants"

module Hanami
  module Middleware
    # @since 1.3.0
    # @api private
    class BodyParser
      require_relative "body_parser/class_interface"
      require_relative "body_parser/parser"

      # @since 1.3.0
      # @api private
      CONTENT_TYPE = "CONTENT_TYPE"

      # @since 1.3.0
      # @api private
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/

      # @since 1.3.0
      # @api private
      RACK_INPUT = "rack.input"

      # @since 1.3.0
      # @api private
      ROUTER_PARAMS = "router.params"

      # @api private
      FALLBACK_KEY = "_"

      extend ClassInterface

      def initialize(app, parsers)
        @app = app
        @parsers = parsers
      end

      def call(env)
        body = env[RACK_INPUT].read
        return @app.call(env) if body.empty?

        env[RACK_INPUT].rewind # somebody might try to read this stream

        if (parser = @parsers[media_type(env)])
          env[Router::ROUTER_PARSED_BODY] = parser.parse(body, env)
          env[ROUTER_PARAMS] = _symbolize(env[Router::ROUTER_PARSED_BODY])
        end

        @app.call(env)
      end

      private

      # @api private
      def _symbolize(body)
        if body.is_a?(::Hash)
          Router::Params.deep_symbolize(body)
        else
          {FALLBACK_KEY => body}
        end
      end

      # @api private
      def _parse(env, body)
        @parsers[
          media_type(env)
        ].parse(body)
      end

      # @api private
      def media_type(env)
        ct = content_type(env)
        return unless ct

        ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
      end

      # @api private
      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
