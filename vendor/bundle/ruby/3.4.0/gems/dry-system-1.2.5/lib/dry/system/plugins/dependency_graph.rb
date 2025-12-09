# frozen_string_literal: true

module Dry
  module System
    module Plugins
      # @api public
      module DependencyGraph
        # @api private
        def self.extended(system)
          super

          system.instance_eval do
            use(:notifications)

            setting :dependency_graph do
              setting :ignored_dependencies, default: []
            end

            after(:configure) do
              self[:notifications].register_event(:resolved_dependency)
              self[:notifications].register_event(:registered_dependency)
            end
          end
        end

        # @api private
        def self.dependencies
          {"dry-events" => "dry/events/publisher"}
        end

        # @api private
        def injector(**options)
          super(**options, strategies: DependencyGraph::Strategies)
        end

        # @api private
        def register(key, contents = nil, options = {}, &)
          super.tap do
            key = key.to_s

            unless config.dependency_graph.ignored_dependencies.include?(key)
              self[:notifications].instrument(
                :registered_dependency,
                key: key,
                class: self[key].class
              )
            end
          end
        end
      end
    end
  end
end
