# frozen_string_literal: true

require "bundler"
require "open3"
require "etc"
require_relative "files"
require_relative "system_call"
require_relative "errors"

module Hanami
  module CLI
    # Conveniences for running `bundler` from CLI commands.
    #
    # @since 2.0.0
    # @api public
    class Bundler
      # @since 2.0.0
      # @api private
      BUNDLE_GEMFILE = "BUNDLE_GEMFILE"
      private_constant :BUNDLE_GEMFILE

      # @since 2.0.0
      # @api private
      DEFAULT_GEMFILE_PATH = "Gemfile"
      private_constant :DEFAULT_GEMFILE_PATH

      # If a `Gemfile` exists, sets up the Bundler environment and loads all the gems from the given
      # groups.
      #
      # This can be called multiple times with different groups.
      #
      # This is a convenience wrapper for `Bundler.require`.
      #
      # @see https://rubydoc.info/gems/bundler/Bundler#require-class_method
      #
      # @return [void]
      #
      # @since 2.0.0
      # @api public
      def self.require(*groups)
        return unless File.exist?(ENV.fetch(BUNDLE_GEMFILE) { DEFAULT_GEMFILE_PATH })

        ::Bundler.require(*groups)
      end

      # Returns a new bundler.
      #
      # @param fs [Hanami::CLI::Files] the filesystem interaction object
      # @param system_call [SystemCall] convenience object for making system calls
      #
      # @since 2.0.0
      # @api public
      def initialize(fs: Hanami::CLI::Files.new, system_call: SystemCall.new)
        @fs = fs
        @system_call = system_call
      end

      # Runs `bundle install` for the Hanami app.
      #
      # @return [SystemCall::Result] the result of the `bundle` command execution
      #
      # @since 2.0.0
      # @api public
      def install
        parallelism_level = Etc.nprocessors
        bundle "install --jobs=#{parallelism_level} --quiet --no-color"
      end

      # Runs `bundle install` for the Hanami app and raises an error if the command does not execute
      # successfully.
      #
      # @return [SystemCall::Result] the result of the `bundle` command execution
      #
      # @raise [Hanami::CLI::BundleInstallError] if the `bundle` command does not execute successfully
      #
      # @since 2.0.0
      # @api public
      def install!
        install.tap do |result|
          raise BundleInstallError.new(result.err) unless result.successful?
        end
      end

      # Runs the given Hanami CLI command via `bundle exec hanami`
      #
      # @return [SystemCall::Result] the result of the command execution
      #
      # @raise [Hanami::CLI::HanamiExecError] if the does not execute successfully
      #
      # @since 2.1.0
      # @api public
      def hanami_exec(cmd, env: nil, &blk)
        exec("hanami #{cmd}", env: env, &blk).tap do |result|
          raise HanamiExecError.new(cmd, result.err) unless result.successful?
        end
      end

      # Executes the given command prefixed by `bundle exec`.
      #
      # @return [SystemCall::Result] the result of the command execution
      #
      # @since 2.0.0
      # @api public
      def exec(cmd, env: nil, &blk)
        bundle("exec #{cmd}", env: env, &blk)
      end

      # Executes the given command prefixed by `bundle`.
      #
      # This is how you should execute all bundle subcommands.
      #
      # @param cmd [String] the commands to prefix with `bundle`
      # @param env [Hash<String, String>] an optional hash of environment variables to set before
      #   executing the command
      #
      # @overload bundle(cmd, env: nil)
      #
      # @overload bundle(cmd, env: nil, &blk)
      #   Executes the command and passes the given block to the `Open3.popen3` method called
      #   internally.
      #
      #   @example
      #     bundle("info") do |stdin, stdout, stderr, wait_thread|
      #       # ...
      #     end
      #
      # @see SystemCall#call
      #
      # @since 2.0.0
      # @api public
      def bundle(cmd, env: nil, &block)
        bundle_bin = which("bundle")
        hanami_env = "HANAMI_ENV=#{env} " unless env.nil?

        system_call.call(
          "#{hanami_env}#{bundle_bin} #{cmd}",
          env: {BUNDLE_GEMFILE => fs.expand_path(DEFAULT_GEMFILE_PATH)},
          &block
        )
      end

      private

      # @return [Hanami::CLI::Files]
      #
      # @since 2.0.0
      # @api public
      attr_reader :fs

      # @return [SystemCall]
      #
      # @since 2.0.0
      # @api public
      attr_reader :system_call

      # Returns the full path to the given executable, or nil if not found in the path.
      #
      # @return [Pathname, nil]
      #
      # @since 2.0.0
      # @api private
      def which(cmd)
        exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
        # Adapted from https://stackoverflow.com/a/5471032/498386
        ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = fs.join(path, "#{cmd}#{ext}")
            return exe if fs.executable?(exe) && !fs.directory?(exe)
          end
        end

        nil
      end
    end
  end
end
