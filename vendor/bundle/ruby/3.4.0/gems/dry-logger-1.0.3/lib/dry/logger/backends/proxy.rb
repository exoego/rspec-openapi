# frozen_string_literal: true

require "delegate"

require "dry/logger/constants"
require "dry/logger/backends/core"

module Dry
  module Logger
    module Backends
      # Logger proxy is used for regular loggers that don't work with log entries
      #
      # @since 1.0.0
      # @api private
      class Proxy < SimpleDelegator
        include Core

        LOG_METHODS.each do |method|
          define_method(method) do |entry|
            if entry.exception?
              if __supports_payload__?(method)
                __getobj__.public_send(method, entry.exception, **entry.payload.except(:exception))
              else
                __getobj__.public_send(method, entry.exception)
              end
            elsif __supports_payload__?(method)
              if entry.message
                __getobj__.public_send(method, entry.message, **entry.payload)
              else
                __getobj__.public_send(method, **entry.payload)
              end
            else
              __getobj__.public_send(method, entry.message)
            end
          end
        end

        # @since 1.0.2
        # @api private
        def initialize(backend, **options)
          super(backend)
          @options = options
          self.log_if = @options[:log_if]
        end

        # @since 1.0.0
        # @api private
        def log?(entry)
          if log_if
            log_if.call(entry)
          else
            true
          end
        end

        private

        # @since 1.0.0
        # @api private
        def __supports_payload__?(method)
          __supported_methods__[method] ||= __getobj__.method(method)
            .parameters.last&.first.equal?(:keyrest)
        end

        # @since 1.0.0
        # @api private
        def __supported_methods__
          @__supported_methods__ ||= {}
        end
      end
    end
  end
end
