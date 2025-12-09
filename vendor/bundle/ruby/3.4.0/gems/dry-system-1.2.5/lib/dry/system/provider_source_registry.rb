# frozen_string_literal: true

require "dry/system/constants"

module Dry
  module System
    # @api private
    class ProviderSourceRegistry
      # @api private
      class Registration
        attr_reader :source
        attr_reader :provider_options

        def initialize(source:, provider_options:)
          @source = source
          @provider_options = provider_options
        end
      end

      attr_reader :sources

      def initialize
        @sources = {}
      end

      def load_sources(path)
        ::Dir[::File.join(path, "**/#{RB_GLOB}")].each do |file|
          require file
        end
      end

      def register(name:, group:, source:, provider_options:)
        sources[key(name, group)] = Registration.new(
          source: source,
          provider_options: provider_options
        )
      end

      def register_from_block(name:, group:, provider_options:, &)
        register(
          name: name,
          group: group,
          source: Provider::Source.for(name: name, group: group, &),
          provider_options: provider_options
        )
      end

      def resolve(name:, group:)
        sources[key(name, group)].tap { |source|
          unless source
            raise ProviderSourceNotFoundError.new(
              name: name,
              group: group,
              keys: sources.keys
            )
          end
        }
      end

      private

      def key(name, group)
        {group: group, name: name}
      end
    end
  end
end
