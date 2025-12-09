# frozen_string_literal: true

require "zeitwerk"

require_relative "transformer/constants"
require_relative "transformer/error"

module Dry
  module Transformer
    # @api public
    # @see Pipe.[]
    def self.[](registry)
      Pipe[registry]
    end

    # @api private
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-transformer"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-transformer.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-transformer.rb",
          "#{root}/dry/transformer/{constants,error,version}.rb"
        )
        loader.inflector.inflect("dsl" => "DSL")
      end
    end

    loader.setup
  end
end
