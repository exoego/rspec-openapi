# frozen_string_literal: true

require "zeitwerk"
require "dry/core"

module Dry
  module AutoInject
    def self.loader
      @loader ||= ::Zeitwerk::Loader.new.tap do |loader|
        root = ::File.expand_path("..", __dir__)
        loader.tag = "dry-auto_inject"
        loader.inflector = ::Zeitwerk::GemInflector.new("#{root}/dry-auto_inject.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-auto_inject.rb",
          "#{root}/dry/auto_inject/version.rb"
        )
      end
    end

    loader.setup
  end

  # Configure an auto-injection module
  #
  # @example
  #    module MyApp
  #      # set up your container
  #      container = Dry::Core::Container.new
  #
  #      container.register(:data_store, -> { DataStore.new })
  #      container.register(:user_repository, -> { container[:data_store][:users] })
  #      container.register(:persist_user, -> { PersistUser.new })
  #
  #      # set up your auto-injection function
  #      AutoInject = Dry::AutoInject(container)
  #
  #      # define your injection function
  #      def self.Inject(*keys)
  #        AutoInject[*keys]
  #      end
  #    end
  #
  #    # then simply include it in your class providing which dependencies should be
  #    # injected automatically from the configured container
  #    class PersistUser
  #      include MyApp::Inject(:user_repository)
  #
  #      def call(user)
  #        user_repository << user
  #      end
  #    end
  #
  #    persist_user = container[:persist_user]
  #
  #    persist_user.call(name: 'Jane')
  #
  # @return [Proc] calling the returned proc builds an auto-injection module
  #
  # @api public
  def self.AutoInject(container, options = {})
    AutoInject::Builder.new(container, options)
  end
end
