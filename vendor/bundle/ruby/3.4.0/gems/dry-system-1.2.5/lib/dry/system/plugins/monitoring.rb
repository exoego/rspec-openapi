# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    module Plugins
      # @api public
      module Monitoring
        # @api private
        def self.extended(system)
          super

          system.use(:notifications)

          system.after(:configure) do
            self[:notifications].register_event(:monitoring)
          end
        end

        # @api private
        def self.dependencies
          {"dry-events": "dry/events/publisher"}
        end

        # @api private
        def monitor(key, **options, &block)
          notifications = self[:notifications]

          resolve(key).tap do |target|
            proxy = Proxy.for(target, **options, key: key)

            if block_given?
              proxy.monitored_methods.each do |meth|
                notifications.subscribe(:monitoring, target: key, method: meth, &block)
              end
            end

            decorate(key, with: -> tgt { proxy.new(tgt, notifications) })
          end
        end
      end
    end
  end
end
