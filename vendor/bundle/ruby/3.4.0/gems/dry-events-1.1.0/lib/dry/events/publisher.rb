# frozen_string_literal: true

require "dry/core"
require "dry/events/constants"
require "dry/events/event"
require "dry/events/bus"
require "dry/events/filter"

module Dry
  module Events
    # Exception raised when the same publisher is registered more than once
    #
    # @api public
    PublisherAlreadyRegisteredError = ::Class.new(::StandardError) do
      # @api private
      def initialize(id)
        super("publisher with id #{id.inspect} already registered as: #{Publisher.registry[id]}")
      end
    end

    # @api public
    InvalidSubscriberError = ::Class.new(::StandardError) do
      # @api private
      def initialize(object_or_event_id)
        case object_or_event_id
        when ::String, ::Symbol
          super(
            "you are trying to subscribe to an event: `#{object_or_event_id}` " \
            "that has not been registered"
          )
        else
          super("you try use subscriber object that will never be executed")
        end
      end
    end

    UnregisteredEventError = ::Class.new(::StandardError) do
      def initialize(object_or_event_id)
        case object_or_event_id
        when ::String, ::Symbol
          super("You are trying to publish an unregistered event: `#{object_or_event_id}`")
        else
          super("You are trying to publish an unregistered event")
        end
      end
    end

    # Extension used for classes that can publish events
    #
    # @example
    #   class AppEvents
    #     include Dry::Events::Publisher[:app]
    #
    #     register_event('users.created')
    #   end
    #
    #   class CreateUser
    #     attr_reader :events
    #
    #     def initialize(events)
    #       @events = events
    #     end
    #
    #     def call(user)
    #       # do your thing
    #       events.publish('users.created', user: user, time: Time.now)
    #     end
    #   end
    #
    #   app_events = AppEvents.new
    #   create_user = CreateUser.new(app_events)
    #
    #   # this will publish "users.created" event with its payload
    #   create_user.call(name: "Jane")
    #
    # @api public
    class Publisher < ::Module
      include ::Dry::Equalizer(:id)

      # Internal publisher registry, which is used to identify them globally
      #
      # This allows us to have listener classes that can subscribe to events
      # without having access to instances of publishers yet.
      #
      # @api private
      def self.registry
        @__registry__ ||= ::Concurrent::Map.new
      end

      # @!attribute [r] :id
      #   @return [Symbol,String] the publisher identifier
      #   @api private
      attr_reader :id

      # Create a publisher extension with the provided identifier
      #
      # @param [Symbol,String] id The identifier
      #
      # @return [Publisher]
      #
      # @raise PublisherAlreadyRegisteredError
      #
      # @api public
      def self.[](id)
        raise PublisherAlreadyRegisteredError, id if registry.key?(id)

        new(id)
      end

      # @api private
      def initialize(id)
        super()
        @id = id
      end

      # Hook for inclusions/extensions
      #
      # It registers the publisher class under global registry using the id
      #
      # @api private
      def included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)

        self.class.registry[id] = klass

        super
      end

      # Class interface for publisher classes
      #
      # @api public
      module ClassMethods
        # Register an event
        #
        # @param [String] event_id The event identifier
        # @param [Hash] payload Optional default payload
        #
        # @api public
        def register_event(event_id, payload = EMPTY_HASH)
          events[event_id] = Event.new(event_id, payload)
          self
        end

        # Subscribe to an event
        #
        # @param [Symbol,String] event_id The event identifier
        # @param [Hash] filter_hash An optional filter for conditional listeners
        #
        # @return [Class] publisher class
        #
        # @api public
        def subscribe(event_id, filter_hash = EMPTY_HASH, &block)
          listeners[event_id] << [block, Filter.new(filter_hash)]
          self
        end

        # Sets up event bus for publisher instances
        #
        # @return [Bus]
        #
        # @api private
        def new_bus
          Bus.new(events: events.dup, listeners: listeners.dup)
        end

        # Global registry with events
        #
        # @api private
        def events
          @__events__ ||= ::Concurrent::Map.new
        end

        # Global registry with listeners
        #
        # @api private
        def listeners
          @__listeners__ ||= LISTENERS_HASH.dup
        end
      end

      # Instance interface for publishers
      #
      # @api public
      module InstanceMethods
        # Register a new event type at instance level
        #
        # @param [Symbol,String] event_id The event identifier
        # @param [Hash] payload Optional default payload
        #
        # @return [self]
        #
        # @api public
        def register_event(event_id, payload = EMPTY_HASH)
          __bus__.events[event_id] = Event.new(event_id, payload)
          self
        end

        # Publish an event
        #
        # @param [String] event_id The event identifier
        # @param [Hash] payload An optional payload
        #
        # @api public
        def publish(event_id, payload = EMPTY_HASH)
          if __bus__.can_handle?(event_id)
            __bus__.publish(event_id, payload)
            self
          else
            raise UnregisteredEventError, event_id
          end
        end
        alias_method :trigger, :publish

        # Subscribe to events.
        #
        # If the filter parameter is provided, filters events by payload.
        #
        # @param [Symbol,String,Object] object_or_event_id The event identifier or a listener object
        # @param [Hash] filter_hash An optional event filter
        #
        # @return [Object] self
        #
        # @api public
        def subscribe(object_or_event_id, filter_hash = EMPTY_HASH, &block)
          if __bus__.can_handle?(object_or_event_id)
            filter = Filter.new(filter_hash)

            if block
              __bus__.subscribe(object_or_event_id, filter, &block)
            else
              __bus__.attach(object_or_event_id, filter)
            end

            self
          else
            raise InvalidSubscriberError, object_or_event_id
          end
        end

        # Unsubscribe a listener
        #
        # @param [Object] listener The listener object
        #
        # @return [self]
        #
        # @api public
        def unsubscribe(listener)
          __bus__.detach(listener)
        end

        # Return true if a given listener has been subscribed to any event
        #
        # @api public
        def subscribed?(listener)
          __bus__.subscribed?(listener)
        end

        # Utility method which yields event with each of its listeners
        #
        # Listeners are already filtered out when filter was provided during
        # subscription
        #
        # @param [Symbol,String] event_id The event identifier
        # param [Hash] payload An optional payload
        #
        # @api public
        def process(event_id, payload = EMPTY_HASH, &)
          __bus__.process(event_id, payload, &)
        end

        # Internal event bus
        #
        # @return [Bus]
        #
        # @api private
        def __bus__
          @__bus__ ||= self.class.new_bus
        end
      end
    end
  end
end
