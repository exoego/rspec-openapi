# frozen_string_literal: true

module Hanami
  class Router
    # Renders a human friendly representation of the routes
    #
    # @api private
    # @since 2.0.0
    module Formatter
      class HumanFriendly
        # @api private
        # @since 2.0.0
        NEW_LINE = $/
        private_constant :NEW_LINE

        # @api private
        # @since 2.0.0
        SMALL_STRING_JUSTIFY_AMOUNT = 8
        private_constant :SMALL_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        MEDIUM_STRING_JUSTIFY_AMOUNT = 20
        private_constant :MEDIUM_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        LARGE_STRING_JUSTIFY_AMOUNT = 30
        private_constant :LARGE_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        EXTRA_LARGE_STRING_JUSTIFY_AMOUNT = 40
        private_constant :EXTRA_LARGE_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        def call(routes)
          routes.filter_map(&method(:format_route_unless_head)).join(NEW_LINE)
        end

        private

        def format_route_unless_head(route)
          !route.head? &&
            [
              route.http_method.to_s.ljust(SMALL_STRING_JUSTIFY_AMOUNT),
              route.path.ljust(LARGE_STRING_JUSTIFY_AMOUNT),
              route.inspect_to.ljust(LARGE_STRING_JUSTIFY_AMOUNT),
              route.as? ? "as #{route.inspect_as}".ljust(MEDIUM_STRING_JUSTIFY_AMOUNT) : "",
              route.constraints? ? "(#{route.inspect_constraints})".ljust(EXTRA_LARGE_STRING_JUSTIFY_AMOUNT) : ""
            ].join
        end
      end
    end
  end
end
