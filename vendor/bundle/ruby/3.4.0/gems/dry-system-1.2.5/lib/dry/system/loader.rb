# frozen_string_literal: true

require "dry/system/errors"

module Dry
  module System
    # Default component loader implementation
    #
    # This class is configured by default for every System::Container. You can
    # provide your own and use it in your containers too.
    #
    # @example
    #   class MyLoader < Dry::System::Loader
    #     def call(*args)
    #       constant.build(*args)
    #     end
    #   end
    #
    #   class MyApp < Dry::System::Container
    #     configure do |config|
    #       # ...
    #       config.component_dirs.loader = MyLoader
    #     end
    #   end
    #
    # @api public
    class Loader
      class << self
        # Requires the component's source file
        #
        # @api public
        def require!(component)
          require(component.require_path)
          self
        end

        # Returns an instance of the component
        #
        # Provided optional args are passed to object's constructor
        #
        # @param [Array] args Optional constructor args
        #
        # @return [Object]
        #
        # @api public
        def call(component, *args, **kwargs)
          require!(component)

          constant = self.constant(component)

          if singleton?(constant)
            constant.instance(*args, **kwargs)
          else
            constant.new(*args, **kwargs)
          end
        end

        # Returns the component's class constant
        #
        # @return [Class]
        #
        # @api public
        def constant(component)
          inflector = component.inflector
          const_name = inflector.camelize(component.const_path)
          inflector.constantize(const_name)
        rescue NameError => exception
          # Ensure it's this component's constant, not any other NameError within the component
          if exception.message =~ /#{const_name}( |\n|$)/
            raise ComponentNotLoadableError.new(component, exception)
          else
            raise exception
          end
        end

        private

        def singleton?(constant)
          constant.respond_to?(:instance) && !constant.respond_to?(:new)
        end
      end
    end
  end
end
