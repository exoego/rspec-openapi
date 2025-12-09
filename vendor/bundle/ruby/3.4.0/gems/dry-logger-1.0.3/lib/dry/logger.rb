# frozen_string_literal: true

if RUBY_VERSION < "3"
  require "backports/3.0.0/hash/except"
end

require "dry/logger/global"
require "dry/logger/constants"
require "dry/logger/clock"
require "dry/logger/dispatcher"

require "dry/logger/formatters/string"
require "dry/logger/formatters/rack"
require "dry/logger/formatters/json"

require "dry/logger/backends/io"
require "dry/logger/backends/file"

module Dry
  # Set up a logger dispatcher
  #
  # @example Basic $stdout string logger
  #   logger = Dry.Logger(:my_app)
  #
  #   logger.info("Hello World!")
  #   # Hello World!
  #
  # @example Customized $stdout string logger
  #   logger = Dry.Logger(:my_app, template: "[%<severity>][%<time>s] %<message>s")
  #
  #   logger.info("Hello World!")
  #   # [INFO][2022-11-06 10:55:12 +0100] Hello World!
  #
  #   logger.info(Hello: "World!")
  #   # [INFO][2022-11-06 10:55:14 +0100] Hello="World!"
  #
  #   logger.warn("Ooops!")
  #   # [WARN][2022-11-06 10:55:57 +0100] Ooops!
  #
  #   logger.error("Gaaah!")
  #   # [ERROR][2022-11-06 10:55:57 +0100] Gaaah!
  #
  # @example Basic $stdout JSON logger
  #   logger = Dry.Logger(:my_app, formatter: :json)
  #
  #   logger.info(Hello: "World!")
  #   # {"progname":"my_app","severity":"INFO","time":"2022-11-06T10:11:29Z","Hello":"World!"}
  #
  # @example Setting up multiple backends
  #   logger = Dry.Logger(:my_app)
  #     add_backend(formatter: :string, template: :details)
  #     add_backend(formatter: :string, template: :details)
  #
  # @example Setting up conditional logging
  #   logger = Dry.Logger(:my_app) { |setup|
  #     setup.add_backend(formatter: :string, template: :details) { |b| b.log_if = :error?.to_proc }
  #   }
  #
  # @param [String, Symbol] id The dispatcher id, can be used as progname in log entries
  # @param [Hash] options Options for backends and formatters
  # @option options [Symbol] :level (:info) The minimum level that should be logged,
  # @option options [Symbol] :stream (optional) The output stream, default is $stdout
  # @option options [Symbol, Class, #call] :formatter (:string) The default formatter or its id,
  # @option options [String, Symbol] :template (:default) The default template that should be used
  # @option options [Boolean] :colorize (false) Enable/disable colorized severity
  # @option options [Hash<Symbol=>Symbol>] :severity_colors ({}) A severity=>color mapping
  # @option options [#call] :on_crash (Dry::Logger::Dispatcher::ON_CRASH) A crash-handling proc.
  #   This is used whenever logging crashes.
  #
  # @since 1.0.0
  # @api public
  # @return [Dispatcher]
  def self.Logger(id, **options, &block)
    Logger::Dispatcher.setup(id, **options, &block)
  end

  module Logger
    extend Global

    # Built-in formatters
    register_formatter(:string, Formatters::String)
    register_formatter(:rack, Formatters::Rack)
    register_formatter(:json, Formatters::JSON)

    # Built-in templates
    register_template(:default, "%<message>s %<payload>s")

    register_template(:details, "[%<progname>s] [%<severity>s] [%<time>s] %<message>s %<payload>s")

    register_template(:crash, <<~STR)
      [%<progname>s] [%<severity>s] [%<time>s] Logging crashed
        %<log_entry>s
        %<message>s (%<exception>s)
      %<backtrace>s
    STR

    register_template(:rack, <<~STR)
      [%<progname>s] [%<severity>s] [%<time>s] \
      %<verb>s %<status>s %<elapsed>s %<ip>s %<path>s %<length>s %<payload>s
        %<params>s
    STR
  end
end
