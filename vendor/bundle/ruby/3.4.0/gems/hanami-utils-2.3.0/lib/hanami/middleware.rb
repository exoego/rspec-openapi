# frozen_string_literal: true

module Hanami
  # Shared Rack middleware for Hanami apps.
  #
  # This module is defined in hanami-utils so that any gem providing middleware can use its
  # resources.
  #
  # @since 2.0.0
  module Middleware
    # Base class for all errors raised during middleware loading.
    #
    # @since 2.0.0
    # @api public
    class Error < StandardError
    end
  end
end
