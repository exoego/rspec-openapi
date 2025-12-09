# frozen_string_literal: true

module Dry
  module System
    module Plugins
      class Zeitwerk < Module
        # @api private
        class CompatInflector
          attr_reader :config

          def initialize(config)
            @config = config
          end

          def camelize(string, _)
            config.inflector.camelize(string)
          end
        end
      end
    end
  end
end
