# frozen_string_literal: true

module Hanami
  class Router
    # Block endpoint
    #
    # @api private
    # @since 2.0.0
    class Block
      # Context to handle a single incoming HTTP request for a block endpoint
      #
      # @since 2.0.0
      class Context
        # @api private
        # @since 2.0.0
        def initialize(blk, env)
          @blk = blk
          @env = env
        end

        # Rack env
        #
        # @return [Hash] the Rack env
        #
        # @since 2.0.0
        attr_reader :env

        # @overload status
        #   Gets the current HTTP status code
        #   @return [Integer] the HTTP status code
        # @overload status(value)
        #   Sets the HTTP status
        #   @param value [Integer] the HTTP status code
        def status(value = nil)
          if value
            @status = value
          else
            @status ||= Router::HTTP_STATUS_OK
          end
        end

        # @overload headers
        #   Gets the current HTTP headers code
        #   @return [Integer] the HTTP headers code
        # @overload headers(value)
        #   Sets the HTTP headers
        #   @param value [Integer] the HTTP headers code
        def headers(value = nil)
          if value
            @headers = value
          else
            @headers ||= {}
          end
        end

        # HTTP Params from URL variables and HTTP body parsing
        #
        # @return [Hash] the HTTP params
        #
        # @since 2.0.0
        def params
          env[Router::PARAMS]
        end

        # @api private
        # @since 2.0.0
        def call
          body = instance_exec(&@blk)
          [status, headers, [body]]
        end
      end

      # @api private
      # @since 2.0.0
      def initialize(context_class, blk)
        @context_class = context_class || Context
        @blk = blk
        freeze
      end

      # @api private
      # @since 2.0.0
      def call(env)
        @context_class.new(@blk, env).call
      end
    end
  end
end
