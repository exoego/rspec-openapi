# frozen_string_literal: true

require "dry/cli"
require "dry/inflector"
require_relative "files"

module Hanami
  module CLI
    # Base class for `hanami` CLI commands.
    #
    # @api public
    # @since 2.0.0
    class Command < Dry::CLI::Command
      # Returns a new command.
      #
      # Provides default values so they can be available to any subclasses defining their own
      # {#initialize} methods.
      #
      # @see #initialize
      #
      # @since 2.1.0
      # @api public
      def self.new(
        out: $stdout,
        err: $stderr,
        fs: Hanami::CLI::Files.new(out: out),
        **opts
      )
        super
      end

      # Returns a new command.
      #
      # This method does not need to be called directly when creating commands for the CLI. Commands
      # are registered as classes, and the CLI framework will initialize the command when needed.
      # This means that all parameters for `#initialize` should also be given default arguments. See
      # {.new} for the standard default arguments for all commands.
      #
      # @param out [IO] I/O stream for standard command output
      # @param err [IO] I/O stream for comment errror output
      # @param fs [Hanami::CLI::Files] object for managing file system interactions
      # @param inflector [Dry::Inflector] inflector for any command-level inflections
      #
      # @see .new
      #
      # @since 2.0.0
      # @api public
      def initialize(out:, err:, fs:)
        super()
        @out = out
        @err = err
        @fs = fs
      end

      def inflector
        @inflector ||= Dry::Inflector.new
      end

      private

      # Returns the I/O stream for standard command output.
      #
      # @return [IO]
      #
      # @since 2.0.0
      # @api public
      attr_reader :out

      # Returns the I/O stream for command error output.
      #
      # @return [IO]
      #
      # @since 2.0.0
      # @api public
      attr_reader :err

      # Returns the object for managing file system interactions.
      #
      # @return [Hanami::CLI::Files]
      #
      # @since 2.0.0
      # @api public
      attr_reader :fs
    end
  end
end
