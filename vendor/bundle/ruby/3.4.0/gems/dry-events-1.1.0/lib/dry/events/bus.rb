# frozen_string_literal: true

require "dry/events/constants"

module Dry
  module Events
    # Event bus
    #
    # An event bus stores listeners (callbacks) and events
    #
    # @api private
    class Bus
      # @!attribute [r] events
      #   @return [Hash] A hash with events registered within a bus
      attr_reader :events

      # @!attribute [r] listeners
      #   @return [Hash] A hash with event listeners registered within a bus
      attr_reader :listeners

      # Initialize a new event bus
      #
      # @param [Hash] events A hash with events
      # @param [Hash] listeners A hash with listeners
      #
      # @api private
      def initialize(events: EMPTY_HASH, listeners: LISTENERS_HASH.dup)
        @listeners = listeners
        @events = events
      end

      # @api private
      def process(event_id, payload)
        listeners[event_id].each do |listener, filter|
          event = events[event_id].payload(payload)

          if filter.(payload)
            yield(event, listener)
          end
        end
      end

      # @api private
      def publish(event_id, payload)
        process(event_id, payload) do |event, listener|
          listener.(event)
        end
      end

      # @api private
      def attach(listener, filter)
        events.each do |id, event|
          meth = event.listener_method

          if listener.respond_to?(meth)
            listeners[id] << [listener.method(meth), filter]
          end
        end
      end

      # @api private
      def detach(listener)
        listeners.each do |id, memo|
          memo.each do |tuple|
            current_listener, _ = tuple
            next unless current_listener.is_a?(Method)

            listeners[id].delete(tuple) if current_listener.receiver.equal?(listener)
          end
        end
      end

      # @api private
      def subscribe(event_id, filter, &block)
        listeners[event_id] << [block, filter]
        self
      end

      # @api private
      def subscribed?(listener)
        listeners.values.any? do |value|
          value.any? do |block, _|
            case listener
            when ::Proc   then block.equal?(listener)
            when ::Method then listener.owner == block.owner && listener.name == block.name
            end
          end
        end
      end

      # @api private
      def can_handle?(object_or_event_id)
        case object_or_event_id
        when ::String, ::Symbol
          events.key?(object_or_event_id)
        else
          events
            .values
            .map(&:listener_method)
            .any?(&object_or_event_id.method(:respond_to?))
        end
      end
    end
  end
end
