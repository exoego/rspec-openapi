# frozen_string_literal: true

require "json"
require_relative "parser"

module Hanami
  module Middleware
    class BodyParser
      # @since 1.3.0
      # @api private
      class JsonParser < Parser
        # @since 1.3.0
        # @api private
        def self.mime_types
          ["application/json", "application/vnd.api+json"]
        end

        # Parse a json string
        #
        # @param body [String] a json string
        #
        # @return [Hash] the parsed json
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] when the body can't be parsed.
        #
        # @since 1.3.0
        # @api private
        def parse(body, *)
          JSON.parse(body)
        rescue StandardError => exception
          raise BodyParsingError.new(exception.message)
        end
      end
    end
  end
end
