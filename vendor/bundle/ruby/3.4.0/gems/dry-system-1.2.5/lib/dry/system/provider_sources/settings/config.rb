# frozen_string_literal: true

module Dry
  module System
    module ProviderSources
      # @api private
      module Settings
        InvalidSettingsError = Class.new(ArgumentError) do
          # @api private
          def initialize(errors)
            message = <<~STR
              Could not load settings. The following settings were invalid:

              #{setting_errors(errors).join("\n")}
            STR

            super(message)
          end

          private

          def setting_errors(errors)
            errors.sort_by { |k, _| k }.map { |key, error| "#{key}: #{error}" }
          end
        end

        # @api private
        class Config
          # @api private
          def self.load(root:, env:, loader: Loader)
            loader = loader.new(root: root, env: env)

            new.tap do |settings_obj|
              errors = {}

              settings.to_a.each do |setting|
                value = loader[setting.name.to_s.upcase]

                begin
                  if value
                    settings_obj.config.public_send(:"#{setting.name}=", value)
                  else
                    settings_obj.config[setting.name]
                  end
                rescue => exception # rubocop:disable Style/RescueStandardError
                  errors[setting.name] = exception
                end
              end

              raise InvalidSettingsError, errors unless errors.empty?
            end
          end

          include Dry::Configurable

          private

          def method_missing(name, ...)
            if config.respond_to?(name)
              config.public_send(name, ...)
            else
              super
            end
          end

          def respond_to_missing?(name, include_all = false)
            config.respond_to?(name, include_all) || super
          end
        end
      end
    end
  end
end
