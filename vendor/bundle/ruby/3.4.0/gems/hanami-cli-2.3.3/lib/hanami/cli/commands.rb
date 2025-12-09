# frozen_string_literal: true

module Hanami
  module CLI
    # Returns true if the CLI is being called from inside an Hanami app.
    #
    # This is typically used to determine whether to register commands that are applicable either
    # inside or outside an app.
    #
    # @return [Boolean]
    #
    # @api private
    # @since 2.0.0
    def self.within_hanami_app?
      require "hanami"

      !!Hanami.app_path
    rescue LoadError => e
      raise e unless e.path == "hanami"

      # If for any reason the hanami gem isn't installed, make a simple best effort to determine
      # whether we're inside an app.
      File.exist?("config/app.rb") || File.exist?("app.rb")
    end

    # Contains the commands available for the current `hanami` CLI execution, depending on whether
    # the CLI is executed inside or outside an Hanami app.
    #
    # @see .within_hanami_app?
    #
    # @api public
    # @since 2.0.0
    module Commands
    end

    # @api private
    def self.register_commands!(within_hanami_app = within_hanami_app?)
      commands = if within_hanami_app
                   require_relative "commands/app"
                   Commands::App
                 else
                   require_relative "commands/gem"
                   Commands::Gem
                 end

      extend(commands)
    end
  end
end
