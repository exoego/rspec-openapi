# frozen_string_literal: true

require "zeitwerk"

require "dry/core"
require "dry/configurable"
require "dry/monitor/version"

module Dry
  module Monitor
    extend Dry::Core::Extensions
    include Dry::Core::Constants

    register_extension(:rack) do
      require "rack/utils"
      require "dry/monitor/rack/logger"
    end

    register_extension(:sql) do
      require "dry/monitor/sql/logger"
    end

    # @api private
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-monitor"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-monitor.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-monitor.rb",
          "#{root}/dry/monitor/version.rb",
          "#{root}/dry/monitor/rack/**/*.rb",
          "#{root}/dry/monitor/sql/**/*.rb"
        )
        loader.inflector.inflect "sql" => "SQL"
      end
    end

    loader.setup
  end
end
