# frozen_string_literal: true

require "time"
require "dry/logger/constants"

module Dry
  module Logger
    # @since 1.0.0
    # @api public
    class Entry
      include Enumerable

      # @since 1.0.0
      # @api public
      attr_reader :progname

      # @since 1.0.0
      # @api public
      attr_reader :severity

      # @since 1.0.0
      # @api public
      attr_reader :tags

      # @since 1.0.0
      # @api public
      attr_reader :level

      # @since 1.0.0
      # @api public
      attr_reader :message

      # @since 1.0.0
      # @api public
      attr_reader :exception

      # @since 1.0.0
      # @api public
      attr_reader :payload

      # @since 1.0.0
      # @api private
      attr_reader :clock

      # @since 1.0.0
      # @api private
      # rubocop:disable Metrics/ParameterLists
      def initialize(clock:, progname:, severity:, tags: EMPTY_ARRAY, message: nil,
                     payload: EMPTY_HASH)
        @clock = clock
        @progname = progname
        @severity = severity.to_s
        @tags = tags
        @level = LEVELS.fetch(severity.to_s)
        @message = message unless message.is_a?(Exception)
        @exception = message if message.is_a?(Exception)
        @payload = build_payload(payload)
      end
      # rubocop:enable Metrics/ParameterLists

      # @since 1.0.0
      # @api public
      def each(&block)
        payload.each(&block)
      end

      # @since 1.0.0
      # @api public
      def [](name)
        payload[name]
      end

      # @since 1.0.0
      # @api public
      def debug?
        level.equal?(DEBUG)
      end

      # @since 1.0.0
      # @api public
      def info?
        level.equal?(INFO)
      end

      # @since 1.0.0
      # @api public
      def warn?
        level.equal?(WARN)
      end

      # @since 1.0.0
      # @api public
      def error?
        level.equal?(ERROR)
      end

      # @since 1.0.0
      # @api public
      def fatal?
        level.equal?(FATAL)
      end

      # @since 1.0.0
      # @api public
      def exception?
        !exception.nil?
      end

      # @since 1.0.0
      # @api public
      def key?(name)
        payload.key?(name)
      end

      # @since 1.0.0
      # @api public
      def tag?(value)
        tags.include?(value)
      end

      # @since 1.0.0
      # @api private
      def meta
        @meta ||= {progname: progname, severity: severity, time: clock.now}
      end

      # @since 1.0.0
      # @api private
      def to_h
        @to_h ||= meta.merge(message: message, **payload)
      end

      # @since 1.0.0
      # @api private
      def filter(filter)
        @payload = filter.call(payload)
        self
      end

      private

      # @since 1.0.0
      # @api private
      def build_payload(payload)
        if exception?
          {exception: exception, **payload}
        else
          payload
        end
      end
    end
  end
end
