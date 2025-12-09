# frozen_string_literal: true

require "logger"

module Dry
  module Logger
    # @since 1.0.0
    # @api private
    NEW_LINE = $/ # rubocop:disable Style/SpecialGlobalVars

    # @since 1.0.0
    # @api private
    SEPARATOR = " "

    # @since 1.0.0
    # @api private
    TAB = SEPARATOR * 2

    # @since 1.0.0
    # @api private
    EMPTY_ARRAY = [].freeze

    # @since 1.0.0
    # @api private
    EMPTY_HASH = {}.freeze

    # @since 1.0.0
    # @api private
    LOG_METHODS = %i[debug info warn error fatal unknown].freeze

    # @since 1.0.0
    # @api private
    BACKEND_METHODS = %i[close].freeze

    # @since 1.0.0
    # @api private
    DEBUG = ::Logger::DEBUG

    # @since 1.0.0
    # @api private
    INFO = ::Logger::INFO

    # @since 1.0.0
    # @api private
    WARN = ::Logger::WARN

    # @since 1.0.0
    # @api private
    ERROR = ::Logger::ERROR

    # @since 1.0.0
    # @api private
    FATAL = ::Logger::FATAL

    # @since 1.0.0
    # @api private
    UNKNOWN = ::Logger::UNKNOWN

    # @since 1.0.0
    # @api private
    LEVEL_RANGE = (DEBUG..UNKNOWN).freeze

    # @since 1.0.0
    # @api private
    DEFAULT_LEVEL = INFO

    # @since 1.0.0
    # @api private
    LEVELS = Hash
      .new { |levels, key|
        LEVEL_RANGE.include?(key) ? key : levels.fetch(key.to_s.downcase, DEFAULT_LEVEL)
      }
      .update(
        "debug" => DEBUG,
        "info" => INFO,
        "warn" => WARN,
        "error" => ERROR,
        "fatal" => FATAL,
        "unknown" => UNKNOWN
      )
      .freeze

    # @since 1.0.0
    # @api private
    DEFAULT_OPTS = {level: DEFAULT_LEVEL, formatter: nil, progname: nil, log_if: nil}.freeze

    # @since 1.0.0
    # @api private
    BACKEND_OPT_KEYS = DEFAULT_OPTS.keys.freeze

    # @since 1.0.0
    # @api private
    FORMATTER_OPT_KEYS = %i[filter].freeze
  end
end
