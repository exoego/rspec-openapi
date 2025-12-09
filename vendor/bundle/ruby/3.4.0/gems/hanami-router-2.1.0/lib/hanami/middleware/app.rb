# frozen_string_literal: true

require "rack/builder"
require_relative "trie"

module Hanami
  module Middleware
    # Hanami Rack middleware stack

    # @since 2.0.0
    # @api private
    class App
      # @param router [Hanami::Router]
      # @param mapping [Hash]
      #
      # @since 2.0.0
      # @api private
      def initialize(router, mapping)
        @trie = Hanami::Middleware::Trie.new(router)

        mapping.each do |path, stack|
          builder = Rack::Builder.new

          stack.each do |middleware, args, kwargs, blk|
            builder.use(middleware, *args, **kwargs, &blk)
          end

          builder.run(router)

          @trie.add(path, builder.to_app.freeze)
        end

        @trie.freeze
        @inspector = router.inspector.freeze
      end

      # @since 2.0.0
      # @api private
      def call(env)
        @trie.find(env[::Rack::PATH_INFO]).call(env)
      end

      # @since 2.0.0
      # @api private
      def to_inspect
        @inspector&.call.to_s
      end
    end
  end
end
