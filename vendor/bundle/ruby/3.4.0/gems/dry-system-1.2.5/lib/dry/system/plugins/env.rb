# frozen_string_literal: true

module Dry
  module System
    module Plugins
      # @api public
      class Env < Module
        DEFAULT_INFERRER = -> { :development }

        attr_reader :options

        # @api private
        def initialize(**options)
          @options = options
          super()
        end

        def inferrer
          options.fetch(:inferrer, DEFAULT_INFERRER)
        end

        # @api private
        def extended(system)
          system.setting :env, default: inferrer.(), reader: true
          super
        end
      end
    end
  end
end
