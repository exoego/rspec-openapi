# frozen_string_literal: true

module Hanami
  module Utils
    # Inheritable class level variable accessors.
    # @since 0.1.0
    #
    # @see Hanami::Utils::ClassAttribute::ClassMethods
    module ClassAttribute
      require "hanami/utils/class_attribute/attributes"

      # @api private
      def self.included(base)
        base.extend ClassMethods
      end

      # @since 0.1.0
      # @api private
      module ClassMethods
        def self.extended(base)
          base.class_eval do
            @__class_attributes = Attributes.new unless defined?(@__class_attributes)
          end
        end

        # Defines a class level accessor for the given attribute(s).
        #
        # A value set for a superclass is automatically available by their
        # subclasses, unless a different value is explicitely set within the
        # inheritance chain.
        #
        # @param attributes [Array<Symbol>] a single or multiple attribute name(s)
        #
        # @return [void]
        #
        # @since 0.1.0
        #
        # @example
        #   require 'hanami/utils/class_attribute'
        #
        #   class Vehicle
        #     include Hanami::Utils::ClassAttribute
        #     class_attribute :engines, :wheels
        #
        #     self.engines = 0
        #     self.wheels  = 0
        #   end
        #
        #   class Car < Vehicle
        #     self.engines = 1
        #     self.wheels  = 4
        #   end
        #
        #   class Airplane < Vehicle
        #     self.engines = 4
        #     self.wheels  = 16
        #   end
        #
        #   class SmallAirplane < Airplane
        #     self.engines = 2
        #     self.wheels  = 8
        #   end
        #
        #   Vehicle.engines # => 0
        #   Vehicle.wheels  # => 0
        #
        #   Car.engines # => 1
        #   Car.wheels  # => 4
        #
        #   Airplane.engines # => 4
        #   Airplane.wheels  # => 16
        #
        #   SmallAirplane.engines # => 2
        #   SmallAirplane.wheels  # => 8
        def class_attribute(*attributes)
          attributes.each do |attr|
            singleton_class.class_eval %(
              def #{attr}                           # def foo
                class_attributes[:#{attr}]          #   class_attributes[:foo]
              end                                   # end
                                                    #
              def #{attr}=(value)                   # def foo=(value)
                class_attributes[:#{attr}] = value  #   class_attributes[:foo] = value
              end                                   # end
            ), __FILE__, __LINE__ - 8
          end
        end

        protected

        # @see Class#inherited
        # @api private
        def inherited(subclass)
          ca = class_attributes.dup
          subclass.class_eval do
            @__class_attributes = ca
          end

          super
        end

        private

        # Class accessor for class attributes.
        # @api private
        def class_attributes
          @__class_attributes
        end
      end
    end
  end
end
