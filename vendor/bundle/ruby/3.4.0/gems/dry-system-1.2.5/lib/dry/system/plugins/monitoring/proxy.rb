# frozen_string_literal: true

require "delegate"

module Dry
  module System
    module Plugins
      module Monitoring
        # @api private
        class Proxy < SimpleDelegator
          # @api private
          def self.for(target, key:, methods: [])
            monitored_methods =
              if methods.empty?
                target.public_methods - Object.public_instance_methods
              else
                methods
              end

            Class.new(self) do
              extend Dry::Core::ClassAttributes
              include Dry::Events::Publisher[target.class.name]

              defines :monitored_methods

              attr_reader :__notifications__

              monitored_methods(monitored_methods)

              monitored_methods.each do |meth|
                define_method(meth) do |*args, **kwargs, &block|
                  object = __getobj__
                  opts = {target: key, object: object, method: meth, args: args, kwargs: kwargs}

                  __notifications__.instrument(:monitoring, opts) do
                    object.public_send(meth, *args, **kwargs, &block)
                  end
                end
              end
            end
          end

          def initialize(target, notifications)
            super(target)
            @__notifications__ = notifications
          end
        end
      end
    end
  end
end
