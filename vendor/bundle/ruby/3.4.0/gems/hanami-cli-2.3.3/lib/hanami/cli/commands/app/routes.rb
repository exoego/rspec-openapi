# frozen_string_literal: true

require "hanami"

module Hanami
  module CLI
    module Commands
      module App
        # Inspect the application routes
        #
        # All the formatters available from `hanami-router` are available:
        #
        # ```
        # $ bundle exec hanami routes --format=csv
        # ```
        #
        # Experimental: You can also use a custom formatter registered in the
        # application container. You can identify it by its key:
        #
        # ```
        # $ bundle exec hanami routes --format=custom_routes_formatter
        # ```
        #
        # @since 2.0.0
        # @api private
        class Routes < Hanami::CLI::Command
          # @since 2.0.0
          # @api private
          DEFAULT_FORMAT = "human_friendly"
          private_constant :DEFAULT_FORMAT

          # @since 2.0.0
          # @api private
          VALID_FORMATS = [
            DEFAULT_FORMAT,
            "csv"
          ].freeze
          private_constant :VALID_FORMATS

          desc "Print app routes"

          option :format,
                 default: DEFAULT_FORMAT,
                 required: false,
                 desc: "Output format"

          example [
            "routes              # Print app routes",
            "routes --format=csv # Print app routes, using CSV format",
          ]

          # @since 2.0.0
          # @api private
          def call(format: DEFAULT_FORMAT, **)
            require "hanami/router/inspector"
            require "hanami/prepare"
            inspector = Hanami::Router::Inspector.new(formatter: resolve_formatter(format))
            app.router(inspector: inspector)
            out.puts inspector.call
          end

          private

          def resolve_formatter(format)
            if VALID_FORMATS.include?(format)
              resolve_formatter_from_hanami_router(format)
            else
              resolve_formatter_from_app(format)
            end
          end

          def resolve_formatter_from_hanami_router(format)
            case format
            when "human_friendly"
              require "hanami/router/formatter/human_friendly"
              Hanami::Router::Formatter::HumanFriendly.new
            when "csv"
              require "hanami/router/formatter/csv"
              Hanami::Router::Formatter::CSV.new
            end
          end

          # Experimental
          def resolve_formatter_from_app(format)
            app[format]
          end

          def app
            Hanami.app
          end
        end
      end
    end
  end
end
