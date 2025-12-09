# frozen_string_literal: true

require "zeitwerk"
require "dry/core"

module Dry
  module System
    # @api private
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-system"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-system.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-system.rb",
          "#{root}/dry/system/{components,constants,errors,stubs,version}.rb"
        )
        loader.inflector.inflect("source_dsl" => "SourceDSL")
      end
    end

    # Registers the provider sources in the files under the given path
    #
    # @api public
    def self.register_provider_sources(path)
      provider_sources.load_sources(path)
    end

    # Registers a provider source, which can be used as the basis for other providers
    #
    # @api public
    def self.register_provider_source(name, group:, source: nil, provider_options: {}, &)
      if source && block_given?
        raise ArgumentError, "You must supply only a `source:` option or a block, not both"
      end

      if source
        provider_sources.register(
          name: name,
          group: group,
          source: source,
          provider_options: provider_options
        )
      else
        provider_sources.register_from_block(
          name: name,
          group: group,
          provider_options: provider_options,
          &
        )
      end
    end

    # @api private
    def self.provider_sources
      @provider_sources ||= ProviderSourceRegistry.new
    end

    loader.setup
  end
end
