# frozen_string_literal: true

require "dry/events/constants"

module Dry
  module Events
    # Event object
    #
    # @api public
    class Event
      include ::Dry::Equalizer(:id, :payload)

      InvalidEventNameError = ::Class.new(::StandardError) do
        # @api private
        def initialize
          super("please provide a valid event name, it could be either String or Symbol")
        end
      end

      DOT = "."
      UNDERSCORE = "_"

      # @!attribute [r] id
      #   @return [Symbol, String] The event identifier
      attr_reader :id

      # @api private
      def self.new(id, payload = EMPTY_HASH)
        return super if (id.is_a?(::String) || id.is_a?(::Symbol)) && !id.empty?

        raise InvalidEventNameError
      end

      # Initialize a new event
      #
      # @param [Symbol, String] id The event identifier
      # @param [Hash] payload
      #
      # @return [Event]
      #
      # @api private
      def initialize(id, payload)
        @id = id
        @payload = payload
      end

      # Get data from the payload
      #
      # @param [String,Symbol] name
      #
      # @api public
      def [](name)
        @payload.fetch(name)
      end

      # Coerce an event to a hash
      #
      # @return [Hash]
      #
      # @api public
      def to_h
        @payload
      end
      alias_method :to_hash, :to_h

      # Get or set a payload
      #
      # @overload
      #   @return [Hash] payload
      #
      # @overload payload(data)
      #   @param [Hash] data A new payload
      #   @return [Event] A copy of the event with the provided payload
      #
      # @api public
      def payload(data = nil)
        if data
          self.class.new(id, @payload.merge(data))
        else
          @payload
        end
      end

      # @api private
      def listener_method
        @listener_method ||= :"on_#{id.to_s.gsub(DOT, UNDERSCORE)}"
      end
    end
  end
end
