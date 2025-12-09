# frozen_string_literal: true

require "csv"

module Hanami
  class Router
    # Renders a CSV representation of the routes
    #
    # You can forward [CSV generation
    # options](https://ruby-doc.org/stdlib-3.1.0/libdoc/csv/rdoc/CSV.html#class-CSV-label-Options+for+Generating]
    # when calling it:
    #
    # ```
    # require "hanami/router/inspector"
    # require "hanami/router/formatter/csv"
    #
    # Hanami::Router::Inspector.new(
    #   routes: Router.routes,
    #   formatter: Hanami::Router::Formatter::CSV.new
    # ).call(write_headers: false)
    # ```
    #
    # @api private
    # @since 2.0.0
    module Formatter
      class CSV
        # @api private
        # @since 2.0.0
        DEFAULT_OPTIONS = {
          write_headers: true
        }.freeze

        # @api private
        # @since 2.0.0
        HEADERS = %w[METHOD PATH TO AS CONSTRAINTS].freeze

        # @api private
        # @since 2.0.0
        def call(routes, **csv_opts)
          ::CSV.generate(**DEFAULT_OPTIONS.merge(csv_opts)) do |csv|
            csv << HEADERS if csv.write_headers?
            routes.reduce(csv) do |acc, route|
              route.head? ? acc : acc << row(route)
            end
          end
        end

        private

        def row(route)
          [
            route.http_method.to_s,
            route.path,
            route.inspect_to,
            route.as? ? route.inspect_as : "",
            route.constraints? ? route.inspect_constraints : ""
          ]
        end
      end
    end
  end
end
