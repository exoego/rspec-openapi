# frozen_string_literal: true

module Dry
  module System
    class Provider
      # Configures a Dry::System::Provider::Source subclass using a DSL that makes it
      # nicer to define source behaviour via a single block.
      #
      # @see Dry::System::Container.register_provider
      #
      # @api private
      class SourceDSL
        def self.evaluate(source_class, &)
          new(source_class).instance_eval(&)
        end

        attr_reader :source_class

        def initialize(source_class)
          @source_class = source_class
        end

        def setting(...)
          source_class.setting(...)
        end

        def prepare(&)
          source_class.define_method(:prepare, &)
        end

        def start(&)
          source_class.define_method(:start, &)
        end

        def stop(&)
          source_class.define_method(:stop, &)
        end

        private

        def method_missing(name, ...)
          if source_class.respond_to?(name)
            source_class.public_send(name, ...)
          else
            super
          end
        end

        def respond_to_missing?(name, include_all = false)
          source_class.respond_to?(name, include_all) || super
        end
      end
    end
  end
end
