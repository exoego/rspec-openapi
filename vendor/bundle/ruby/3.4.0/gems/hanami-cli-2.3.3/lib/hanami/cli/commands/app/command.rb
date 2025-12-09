# frozen_string_literal: true

require "hanami/env"
require_relative "db/utils/database"
require_relative "../../files"

module Hanami
  module CLI
    module Commands
      module App
        # Base class for `hanami` CLI commands intended to be executed within an existing Hanami
        # app.
        #
        # @since 2.0.0
        # @api public
        class Command < Hanami::CLI::Command
          # Overloads {Hanami::CLI::Commands::App::Command#call} to ensure an appropriate
          # `HANAMI_ENV` environment variable is set.
          #
          # Uses an `--env` option if provided, then falls back to an already-set `HANAMI_ENV`
          # environment variable, and defaults to "development" in the absence of both.
          #
          # @since 2.0.0
          # @api private
          module Environment
            # @since 2.2.0
            # @api private
            def self.prepended(klass)
              # This module is included each time the class is inherited from
              # Without this check, the --env option is duplicated each time
              unless klass.options.map(&:name).include?(:env)
                klass.option :env, desc: "App environment (development, test, production)", aliases: ["e"]
              end
            end

            # @since 2.0.0
            # @api private
            def call(*args, **opts)
              env = opts[:env]

              hanami_env = env ? env.to_s : ENV.fetch("HANAMI_ENV", "development")

              ENV["HANAMI_ENV"] = hanami_env
              Hanami::Env.load

              super
            rescue FileAlreadyExistsError => error
              err.puts(error.message)
              exit(1)
            end
          end

          # @since 2.0.0
          # @api private
          def self.inherited(klass)
            super
            klass.prepend(Environment)
          end

          # Returns the Hanami app class.
          #
          # @return [Hanami::App] the Hanami app
          #
          # @raise [Hanami::AppLoadError] if the app has not been loaded
          #
          # @since 2.0.0
          # @api public
          def app
            @app ||=
              begin
                require "hanami/prepare"
                Hanami.app
              end
          end

          def inflector = app.inflector

          # Runs another CLI command via its command class.
          #
          # @param klass [Hanami::CLI::Command]
          # @param args [Array] any additional arguments to pass to the command's `#call` method.
          #
          # @since 2.0.0
          # @api public
          def run_command(klass, ...)
            klass.new(
              out: out,
              fs: Hanami::CLI::Files,
            ).call(...)
          end

          # Executes a given block and prints string to the `out` stream with details of the time
          # taken to execute.
          #
          # If the block returns a falsey value, then a failure message is printed.
          #
          # @example
          #   measure("Reverse the polarity of the neutron flow") do
          #     # reverses the polarity, returns a truthy value
          #   end
          #   # printed to `out`:
          #   # => Reverse the polarity of the neutron flow in 2s
          #
          # @example
          #   measure("Disable the time dilation device") do
          #     # attempts to disable the device, returns a falsey favlue
          #   end
          #   # printed to `out`:
          #   # !!! => Disable the time dilation device FAILED
          #
          # @since 2.0.0
          # @api public
          def measure(desc)
            start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            result = yield
            stop = Process.clock_gettime(Process::CLOCK_MONOTONIC)

            if result
              out.puts "=> #{desc} in #{(stop - start).round(4)}s"
            else
              out.puts "!!! => #{desc.inspect} FAILED"
            end
          end
        end
      end
    end
  end
end
