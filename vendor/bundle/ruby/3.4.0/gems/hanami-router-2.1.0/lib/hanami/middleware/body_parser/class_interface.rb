# frozen_string_literal: true

require_relative "errors"

module Hanami
  module Middleware
    # HTTP request body parser
    class BodyParser
      # @api private
      # @since 1.3.0
      module ClassInterface
        # Instantiate a new body parser instance and load its parsers
        #
        # @example
        #   Hanami::Middleware::BodyParser.new(->(env) { [200, {}, "app"] }, :json)
        #
        #   Hanami::Middleware::BodyParser.new(
        #     ->(env) { [200, {}, "app"] }, [json: "application/json+scim"]
        #   )
        #
        #   Hanami::Middleware::BodyParser.new(
        #     ->(env) { [200, {}, "app"] }, [json: ["application/json+scim", "application/ld+json"]]
        #   )
        #
        # @param app [#call]
        # @param parser_specs [Symbol, Array<Hash>] parser name or name with mime-type(s)
        #
        # @api private
        # @since 2.0.0
        # @return BodyParser
        def new(app, parser_specs)
          super(app, build_parsers(parser_specs))
        end

        # @api private
        # @since 1.3.0
        def build(parser, **config)
          parser =
            case parser
            when String, Symbol
              build(parser_class(parser), **config)
            when Class
              parser.new(**config)
            else
              parser
            end

          ensure_parser parser

          parser
        end

        # @api private
        # @since 2.0.0
        def build_parsers(parser_specs, registry = {})
          return DEFAULT_BODY_PARSERS if parser_specs.empty?

          parsers = Array(parser_specs).flatten(0)

          parsers.each_with_object(registry) do |spec, memo|
            if spec.is_a?(Hash) && spec.size > 1
              spec.each do |key, value|
                build_parsers([key => [value]], memo)
              end
            else
              name, *mime_types = Array(*spec).flatten(0)

              parser = build(name, mime_types: mime_types.flatten)

              parser.mime_types.each do |mime|
                memo[mime] = parser
              end
            end
          end
        end

        private

        # @api private
        # @since 1.3.0
        PARSER_METHODS = %i[mime_types parse].freeze

        # @api private
        # @since 2.0.0
        DEFAULT_BODY_PARSERS = {}.freeze

        # @api private
        # @since 1.3.0
        def ensure_parser(parser)
          unless PARSER_METHODS.all? { |method| parser.respond_to?(method) }
            raise InvalidParserError.new(parser)
          end
        end

        # @api private
        # @since 1.3.0
        # rubocop:disable Lint/SuppressedException
        def parser_class(parser_name)
          parser = nil

          begin
            require "hanami/middleware/body_parser/#{parser_name}_parser"
          rescue LoadError; end

          begin
            parser = load_parser!("#{classify(parser_name)}Parser")
          rescue NameError; end

          parser
        ensure
          raise UnknownParserError, parser_name unless parser
        end
        # rubocop:enable Lint/SuppressedException

        # @api private
        # @since 1.3.0
        def classify(parser)
          parser.to_s.split("_").map(&:capitalize).join
        end

        # @api private
        # @since 1.3.0
        def load_parser!(class_name)
          Hanami::Middleware::BodyParser.const_get(class_name, false)
        end
      end
    end
  end
end
