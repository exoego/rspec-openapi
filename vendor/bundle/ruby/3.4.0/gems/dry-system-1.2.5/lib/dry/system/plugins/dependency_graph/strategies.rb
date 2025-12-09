# frozen_string_literal: true

module Dry
  module System
    module Plugins
      module DependencyGraph
        # @api private
        class Strategies
          extend Core::Container::Mixin

          # @api private
          class Kwargs < Dry::AutoInject::Strategies::Kwargs
            private

            # @api private
            def define_initialize(klass)
              @container["notifications"].instrument(
                :resolved_dependency,
                dependency_map: dependency_map.to_h,
                target_class: klass
              )

              super
            end
          end

          # @api private
          class Args < Dry::AutoInject::Strategies::Args
            private

            # @api private
            def define_initialize(klass)
              @container["notifications"].instrument(
                :resolved_dependency,
                dependency_map: dependency_map.to_h,
                target_class: klass
              )

              super
            end
          end

          class Hash < Dry::AutoInject::Strategies::Hash
            private

            # @api private
            def define_initialize(klass)
              @container["notifications"].instrument(
                :resolved_dependency,
                dependency_map: dependency_map.to_h,
                target_class: klass
              )

              super
            end
          end

          register :kwargs, Kwargs
          register :args, Args
          register :hash, Hash
          register :default, Kwargs
        end
      end
    end
  end
end
