# frozen_string_literal: true

require "set"
require "dry/logger/constants"
require_relative "colors"

module Dry
  module Logger
    module Formatters
      # Basic string formatter.
      #
      # This formatter returns log entries in key=value format.
      #
      # @since 1.0.0
      # @api public
      class Template
        # @since 1.0.0
        # @api private
        TOKEN_REGEXP = /%<(\w*)>s/.freeze

        # @since 1.0.0
        # @api private
        MESSAGE_TOKEN = "%<message>s"

        # @since 1.0.0
        # @api private
        attr_reader :value

        # @since 1.0.0
        # @api private
        attr_reader :tokens

        # @since 1.0.0
        # @api private
        def self.[](value)
          cache.fetch(value) {
            cache[value] = (colorized?(value) ? Template::Colorized : Template).new(value)
          }
        end

        # @since 1.0.0
        # @api private
        private_class_method def self.colorized?(value)
          Colors::COLORS.keys.any? { |color| value.include?("<#{color}>") }
        end

        # @since 1.0.0
        # @api private
        private_class_method def self.cache
          @cache ||= {}
        end

        # @since 1.0.0
        # @api private
        class Colorized < Template
          # @since 1.0.0
          # @api private
          def initialize(value)
            super(Colors.evaluate(value))
          end
        end

        # @since 1.0.0
        # @api private
        def initialize(value)
          @value = value
          @tokens = value.scan(TOKEN_REGEXP).flatten(1).map(&:to_sym).to_set
        end

        # @since 1.0.0
        # @api private
        def %(tokens)
          output = value % tokens
          output.strip!
          output.split(NEW_LINE).map(&:rstrip).join(NEW_LINE)
        end

        # @since 1.0.0
        # @api private
        def colorize(color, input)
          "\e[#{Colors[color.to_sym]}m#{input}\e[0m"
        end

        # @since 1.0.0
        # @api private
        def include?(token)
          tokens.include?(token)
        end
      end
    end
  end
end
