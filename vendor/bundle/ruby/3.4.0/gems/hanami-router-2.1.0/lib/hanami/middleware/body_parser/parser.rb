# frozen_string_literal: true

module Hanami
  module Middleware
    class BodyParser
      # Body parser abstract class
      #
      # @since 2.0.0
      class Parser
        DEFAULT_MIME_TYPES = [].freeze

        # Return supported mime types
        #
        # @return [Array<String>] supported MIME types
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def self.mime_types
        #       ["application/xml", "text/xml"]
        #     end
        #   end
        attr_reader :mime_types

        # @api private
        def initialize(mime_types: DEFAULT_MIME_TYPES)
          @mime_types = self.class.mime_types + mime_types
        end

        # Parse raw HTTP request body
        #
        # @param body [String] HTTP request body
        # @param env [Hash] Rack env
        #
        # @return [Hash] the result of the parsing
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] the error
        #   that must be raised if the parsing cannot be accomplished
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def parse(body)
        #       # XML parsing
        #       # ...
        #     rescue => exception
        #       raise Hanami::Middleware::BodyParser::BodyParsingError.new(exception.message)
        #     end
        #   end
        def parse(body, env = {}) # rubocop:disable Lint/UnusedMethodArgument
          raise NoMethodError
        end
      end
    end
  end
end
