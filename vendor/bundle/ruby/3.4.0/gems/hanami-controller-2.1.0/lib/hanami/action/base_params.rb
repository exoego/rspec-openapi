# frozen_string_literal: true

require "rack/request"
require "hanami/utils/hash"

module Hanami
  class Action
    # Provides access to params included in a Rack request.
    #
    # Offers useful access to params via methods like {#[]}, {#get} and {#to_h}.
    #
    # These params are available via {Request#params}.
    #
    # This class is used by default when {Hanami::Action::Validatable} is not included, or when no
    # {Validatable::ClassMethods#params params} validation schema is defined.
    #
    # @see Hanami::Action::Request#params
    #
    # @api private
    # @since 0.7.0
    class BaseParams
      # @attr_reader env [Hash] the Rack env
      #
      # @since 0.7.0
      # @api private
      attr_reader :env

      # @attr_reader raw [Hash] the raw params from the request
      #
      # @since 0.7.0
      # @api private
      attr_reader :raw

      # Returns a new frozen params object for the Rack env.
      #
      # @param env [Hash] a Rack env or an hash of params.
      #
      # @since 0.7.0
      # @api private
      def initialize(env)
        @env    = env
        @raw    = _extract_params
        @params = Utils::Hash.deep_symbolize(@raw)
        freeze
      end

      # Returns the value for the given params key.
      #
      # @param key [Symbol] the key
      #
      # @return [Object,nil] the associated value, if found
      #
      # @since 0.7.0
      # @api public
      def [](key)
        @params[key]
      end

      # Returns an value associated with the given params key.
      #
      # You can access nested attributes by listing all the keys in the path. This uses the same key
      # path semantics as `Hash#dig`.
      #
      # @param keys [Array<Symbol,Integer>] the key
      #
      # @return [Object,NilClass] return the associated value, if found
      #
      # @example
      #   require "hanami/controller"
      #
      #   module Deliveries
      #     class Create < Hanami::Action
      #       def handle(req, *)
      #         req.params.get(:customer_name)     # => "Luca"
      #         req.params.get(:uknown)            # => nil
      #
      #         req.params.get(:address, :city)    # => "Rome"
      #         req.params.get(:address, :unknown) # => nil
      #
      #         req.params.get(:tags, 0)           # => "foo"
      #         req.params.get(:tags, 1)           # => "bar"
      #         req.params.get(:tags, 999)         # => nil
      #
      #         req.params.get(nil)                # => nil
      #       end
      #     end
      #   end
      #
      # @since 0.7.0
      # @api public
      def get(*keys)
        @params.dig(*keys)
      end

      # This is for compatibility with Hanami::Helpers::FormHelper::Values
      #
      # @api private
      # @since 0.8.0
      alias_method :dig, :get

      # Returns true at all times, providing a common interface with {Params}.
      #
      # @return [TrueClass] always returns true
      #
      # @see Hanami::Action::Params#valid?
      #
      # @api public
      # @since 0.7.0
      def valid?
        true
      end

      # Returns a hash of the parsed request params.
      #
      # @return [Hash]
      #
      # @since 0.7.0
      # @api public
      def to_h
        @params
      end
      alias_method :to_hash, :to_h

      # Iterates over the params.
      #
      # Calls the given block with each param key-value pair; returns the full hash of params.
      #
      # @yieldparam key [Symbol]
      # @yieldparam value [Object]
      #
      # @return [to_h]
      #
      # @since 0.7.1
      # @api public
      def each(&blk)
        to_h.each(&blk)
      end

      private

      # @since 0.7.0
      # @api private
      def _extract_params
        result = {}

        if env.key?(Action::RACK_INPUT)
          result.merge! ::Rack::Request.new(env).params
          result.merge! _router_params
        else
          result.merge! _router_params(env)
          env[Action::REQUEST_METHOD] ||= Action::DEFAULT_REQUEST_METHOD
        end

        result
      end

      # @since 0.7.0
      # @api private
      def _router_params(fallback = {})
        env.fetch(ROUTER_PARAMS) do
          if session = fallback.delete(Action::RACK_SESSION)
            fallback[Action::RACK_SESSION] = Utils::Hash.deep_symbolize(session)
          end

          fallback
        end
      end
    end
  end
end
