# frozen_string_literal: true

module Dry
  module Logger
    module Formatters
      # Shell colorizer
      #
      # This was ported from hanami-utils
      #
      # @since 1.0.0
      # @api private
      class Colors
        # Unknown color code error
        #
        # @since 1.0.0
        class UnknownColorCodeError < StandardError
          def initialize(code)
            super("Unknown color code: `#{code.inspect}'")
          end
        end

        # Escapes codes for terminals to output strings in colors
        #
        # @since 1.2.0
        # @api private
        COLORS = {black: 30,
                  red: 31,
                  green: 32,
                  yellow: 33,
                  blue: 34,
                  magenta: 35,
                  cyan: 36,
                  gray: 37}.freeze

        # @api private
        def self.evaluate(input)
          COLORS.keys.reduce(input.dup) { |output, color|
            output.gsub!("<#{color}>", start(color))
            output.gsub!("</#{color}>", stop)
            output
          }
        end

        # Colorizes output
        # 8 colors available: black, red, green, yellow, blue, magenta, cyan, and gray
        #
        # @param input [#to_s] the string to colorize
        # @param color [Symbol] the color
        #
        # @raise [UnknownColorError] if the color code is unknown
        #
        # @return [String] the colorized string
        #
        # @since 1.0.0
        # @api private
        def self.call(color, input)
          "#{start(color)}#{input}#{stop}"
        end

        # @since 1.0.0
        # @api private
        def self.start(color)
          "\e[#{self[color]}m"
        end

        # @since 1.0.0
        # @api private
        def self.stop
          "\e[0m"
        end

        # Helper method to translate between color names and terminal escape codes
        #
        # @since 1.0.0
        # @api private
        #
        # @raise [UnknownColorError] if the color code is unknown
        def self.[](code)
          COLORS.fetch(code) { raise UnknownColorCodeError, code }
        end
      end
    end
  end
end
