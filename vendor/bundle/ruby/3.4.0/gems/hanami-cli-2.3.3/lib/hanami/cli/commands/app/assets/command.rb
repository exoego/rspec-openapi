# frozen_string_literal: true

require "shellwords"
require_relative "../command"
require_relative "../../../interactive_system_call"

module Hanami
  module CLI
    module Commands
      module App
        module Assets
          # Base class for assets commands.
          #
          # Finds slices with assets present (anything in an `assets/` dir), then forks a child
          # process for each slice to run the assets command (`config/assets.js`) for the slice.
          #
          # Prefers the slice's own `config/assets.js` if present, otherwise falls back to the
          # app-level file.
          #
          # Passes `--path` and `--dest` arguments to this command to compile assets for the given
          # slice only and save them into a dedicated directory (`public/assets/` for the app,
          # `public/[slice_name]/` for slices).
          #
          # @see Watch
          # @see Compile
          #
          # @since 2.1.0
          # @api private
          class Command < App::Command
            # @since 2.1.0
            # @api private
            def initialize(
              out:, err:,
              config: app.config.assets,
              system_call: InteractiveSystemCall.new(out: out, err: err, exit_after: false),
              **opts
            )
              super(out: out, err: err, **opts)

              @config = config
              @system_call = system_call
            end

            # @since 2.1.0
            # @api private
            def call(**)
              slices = slices_with_assets

              if slices.empty?
                out.puts "No assets found."
                return
              end

              slices.each do |slice|
                unless assets_config(slice)
                  out.puts "No assets config found for #{slice}. Please create a config/assets.js."
                  return
                end
              end

              pids = slices_with_assets.map { |slice| fork_child_assets_command(slice) }

              Signal.trap("INT") do
                pids.each do |pid|
                  Process.kill("INT", pid)
                end
              end

              Process.waitall
            end

            private

            # @since 2.1.0
            # @api private
            attr_reader :config

            # @since 2.1.0
            # @api private
            attr_reader :system_call

            # @since 2.1.0
            # @api private
            def fork_child_assets_command(slice)
              Process.fork do
                cmd, *args = assets_command(slice)
                system_call.call(cmd, *args, out_prefix: "[#{slice.slice_name}] ")
              rescue Interrupt
                # When this has been interrupted (by the Signal.trap handler in #call), catch the
                # interrupt and exit cleanly, without showing the default full backtrace.
              end
            end

            # @since 2.1.0
            # @api private
            def assets_command(slice)
              cmd = [config.node_command, assets_config(slice).to_s, "--"]

              if slice.eql?(slice.app)
                cmd << "--path=app"
                cmd << "--dest=public/assets"
              else
                cmd << "--path=#{slice.root.relative_path_from(slice.app.root)}"
                cmd << "--dest=public/assets/#{Hanami::Assets.public_assets_dir(slice)}"
              end

              cmd
            end

            # @since 2.1.0
            # @api private
            def slices_with_assets
              slices = app.slices.with_nested + [app]
              slices.select { |slice| slice_assets?(slice) }
            end

            # @since 2.1.0
            # @api private
            def slice_assets?(slice)
              assets_path =
                if slice.app.eql?(slice)
                  slice.root.join("app", "assets")
                else
                  slice.root.join("assets")
                end

              assets_path.directory?
            end

            # Returns the path to the assets config (`config/assets.js`) for the given slice.
            #
            # Prefers a config file local to the slice, otherwise falls back to app-level config.
            # Returns nil if no config can be found.
            #
            # @since 2.1.0
            # @api private
            def assets_config(slice)
              config = slice.root.join("config", "assets.js")
              return config if config.exist?

              config = slice.app.root.join("config", "assets.js")
              config if config.exist?
            end

            # @since 2.1.0
            # @api private
            def escape(str)
              Shellwords.shellescape(str)
            end
          end
        end
      end
    end
  end
end
