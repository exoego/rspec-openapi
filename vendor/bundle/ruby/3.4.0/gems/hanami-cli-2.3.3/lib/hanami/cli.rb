# frozen_string_literal: true

require "dry/cli"
require "zeitwerk"

module Hanami
  # Extensible command line interface for Hanami.
  #
  # @api public
  # @since 2.0.0
  module CLI
    # @api private
    # @since 2.0.0
    def self.gem_loader
      @gem_loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "hanami-cli"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/hanami-cli.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/hanami-cli.rb",
          "#{root}/hanami/cli/{errors,version}.rb"
        )
        loader.inflector.inflect("cli" => "CLI")
        loader.inflector.inflect("db" => "DB")
        loader.inflector.inflect("url" => "URL")
      end
    end

    gem_loader.setup
    require_relative "cli/commands"
    require_relative "cli/errors"
    require_relative "cli/version"

    extend Dry::CLI::Registry

    register_commands!
  end
end
