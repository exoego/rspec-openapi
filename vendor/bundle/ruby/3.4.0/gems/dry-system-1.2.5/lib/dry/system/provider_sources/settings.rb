# frozen_string_literal: true

module Dry
  module System
    module ProviderSources
      module Settings
        class Source < Dry::System::Provider::Source
          setting :store

          def prepare
            require "dry/system/provider_sources/settings/config"
          end

          def start
            register(:settings, settings.load(root: target.root, env: target.config.env))
          end

          def settings(&block)
            # Save the block and evaluate it lazily to allow a provider with this source
            # to `require` any necessary files for the block to evaluate correctly (e.g.
            # requiring an app-specific types module for setting constructors)
            if block
              @settings_block = block
            elsif defined? @settings_class
              @settings_class
            elsif @settings_block
              @settings_class = Class.new(Settings::Config, &@settings_block)
            end
          end
        end
      end
    end
  end
end

Dry::System.register_provider_source(
  :settings,
  group: :dry_system,
  source: Dry::System::ProviderSources::Settings::Source
)
