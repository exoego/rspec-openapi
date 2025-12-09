# frozen_string_literal: true

require "dry/core/container/stub"

module Dry
  module System
    class Container
      # @api private
      module Stubs
        # This overrides default finalize! just to disable automatic freezing
        # of the container
        #
        # @api private
        def finalize!(**, &)
          super(freeze: false, &)
        end
      end

      # Enables stubbing container's components
      #
      # @example
      #   require 'dry/system/stubs'
      #
      #   MyContainer.enable_stubs!
      #   MyContainer.finalize!
      #
      #   MyContainer.stub('some.component', some_stub_object)
      #
      # @return Container
      #
      # @api public
      def self.enable_stubs!
        super
        extend ::Dry::System::Container::Stubs
        self
      end
    end
  end
end
