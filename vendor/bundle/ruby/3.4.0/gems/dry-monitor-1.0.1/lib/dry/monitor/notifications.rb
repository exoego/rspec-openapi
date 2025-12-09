# frozen_string_literal: true

require "dry/events/publisher"

module Dry
  module Monitor
    CLOCK = Clock.new

    class Notifications
      include Core::Constants
      include Events::Publisher["Dry::Monitor::Notifications"]

      attr_reader :id, :clock

      def initialize(id, clock: CLOCK)
        @id = id
        @clock = clock
      end

      def start(event_id, payload)
        instrument(event_id, payload)
      end

      def stop(event_id, payload)
        instrument(event_id, payload)
      end

      def instrument(event_id, payload = EMPTY_HASH, &block)
        result, time = @clock.measure(&block) if block_given?

        process(event_id, payload) do |event, listener|
          if time
            listener.(event.payload(payload.merge(time: time)))
          else
            listener.(event)
          end
        end

        result
      end
    end
  end
end
