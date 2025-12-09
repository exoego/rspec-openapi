# frozen_string_literal: true

require "date"
require "time"
require "bigdecimal"
require "bigdecimal/util"

module Dry
  module Transformer
    # Coercion functions for common types
    #
    # @api public
    module Coercions
      extend Registry

      TRUE_VALUES = [true, 1, "1", "on", "t", "true", "y", "yes"].freeze
      FALSE_VALUES = [false, 0, "0", "off", "f", "false", "n", "no", nil].freeze

      BOOLEAN_MAP = Hash[
        TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])
      ].freeze

      # Does nothing and returns a value
      #
      # @example
      #   fn = Coercions[:identity]
      #   fn[:foo] # => :foo
      #
      # @param [Object] value
      #
      # @return [Object]
      #
      # @api public
      def self.identity(value = nil)
        value
      end

      # Coerce value into a string
      #
      # @example
      #   Dry::Transformer(:to_string)[1]
      #   # => "1"
      #
      # @param [Object] value The input value
      #
      # @return [String]
      #
      # @api public
      def self.to_string(value)
        value.to_s
      end

      # Coerce value into a symbol
      #
      # @example
      #   Dry::Transformer(:to_symbol)['foo']
      #   # => :foo
      #
      # @param [#to_s] value The input value
      #
      # @return [Symbol]
      #
      # @api public
      def self.to_symbol(value)
        value.to_s.to_sym
      end

      # Coerce value into a integer
      #
      # @example
      #   Dry::Transformer(:to_integer)['1']
      #   # => 1
      #
      # @param [Object] value The input value
      #
      # @return [Integer]
      #
      # @api public
      def self.to_integer(value)
        value.to_i
      end

      # Coerce value into a float
      #
      # @example
      #   Dry::Transformer(:to_float)['1.2']
      #   # => 1.2
      #
      # @param [Object] value The input value
      #
      # @return [Float]
      #
      # @api public
      def self.to_float(value)
        value.to_f
      end

      # Coerce value into a decimal
      #
      # @example
      #   Dry::Transformer(:to_decimal)[1.2]
      #   # => #<BigDecimal:7fca32acea50,'0.12E1',18(36)>
      #
      # @param [Object] value The input value
      #
      # @return [Decimal]
      #
      # @api public
      def self.to_decimal(value)
        value.to_d
      end

      # Coerce value into a boolean
      #
      # @example
      #   Dry::Transformer(:to_boolean)['true']
      #   # => true
      #   Dry::Transformer(:to_boolean)['f']
      #   # => false
      #
      # @param [Object] value The input value
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      def self.to_boolean(value)
        BOOLEAN_MAP.fetch(value)
      end

      # Coerce value into a date
      #
      # @example
      #   Dry::Transformer(:to_date)['2015-04-14']
      #   # => #<Date: 2015-04-14 ((2457127j,0s,0n),+0s,2299161j)>
      #
      # @param [Object] value The input value
      #
      # @return [Date]
      #
      # @api public
      def self.to_date(value)
        Date.parse(value)
      end

      # Coerce value into a time
      #
      # @example
      #   Dry::Transformer(:to_time)['2015-04-14 12:01:45']
      #   # => 2015-04-14 12:01:45 +0200
      #
      # @param [Object] value The input value
      #
      # @return [Time]
      #
      # @api public
      def self.to_time(value)
        Time.parse(value)
      end

      # Coerce value into a datetime
      #
      # @example
      #   Dry::Transformer(:to_datetime)['2015-04-14 12:01:45']
      #   # => #<DateTime: 2015-04-14T12:01:45+00:00 ((2457127j,43305s,0n),+0s,2299161j)>
      #
      # @param [Object] value The input value
      #
      # @return [DateTime]
      #
      # @api public
      def self.to_datetime(value)
        DateTime.parse(value)
      end

      # Coerce value into an array containing tuples only
      #
      # If the source is not an array, or doesn't contain a tuple, returns
      # an array with one empty tuple
      #
      # @example
      #   Dry::Transformer(:to_tuples)[:foo]                  # => [{}]
      #   Dry::Transformer(:to_tuples)[[]]                    # => [{}]
      #   Dry::Transformer(:to_tuples)[[{ foo: :FOO, :bar }]] # => [{ foo: :FOO }]
      #
      # @param [Object] value
      #
      # @return [Array<Hash>]
      #
      def self.to_tuples(value)
        array = value.is_a?(Array) ? Array[*value] : [{}]
        array.select! { |item| item.is_a?(Hash) }
        array.any? ? array : [{}]
      end
    end
  end
end
