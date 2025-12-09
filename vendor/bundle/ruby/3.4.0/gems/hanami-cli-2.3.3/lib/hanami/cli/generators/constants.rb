# frozen_string_literal: true

module Hanami
  module CLI
    # @since 2.2.0
    # @api private
    module Generators
      # @since 2.2.0
      # @api private
      INDENTATION = "  "
      private_constant :INDENTATION

      # @since 2.2.0
      # @api private
      OFFSET = INDENTATION
      private_constant :OFFSET

      # @since 2.2.0
      # @api private
      NESTED_OFFSET = INDENTATION * 2
      private_constant :OFFSET

      # @since 2.2.0
      # @api private
      KEY_SEPARATOR = %r{::|[.\/]}
      private_constant :KEY_SEPARATOR

      # @since 2.2.0
      # @api private
      MATCHER_PATTERN = /::|\./
      private_constant :MATCHER_PATTERN

      # @since 2.2.0
      # @api private
      NAMESPACE_SEPARATOR = "::"
      private_constant :NAMESPACE_SEPARATOR
    end
  end
end
