# frozen_string_literal: true

require "logger"
require "pathname"

require "dry/logger/constants"
require "dry/logger/backends/proxy"
require "dry/logger/entry"

module Dry
  module Logger
    # Logger dispatcher routes log entries to configured logging backends
    #
    # @since 1.0.0
    # @api public
    class Dispatcher
      # @since 1.0.0
      # @api private
      attr_reader :id

      # (EXPERIMENTAL) Shared payload context
      #
      # @example
      #   logger.context[:component] = "test"
      #
      #   logger.info "Hello World"
      #   # Hello World component=test
      #
      # @since 1.0.0
      # @api public
      attr_reader :context

      # @since 1.0.0
      # @api private
      attr_reader :backends

      # @since 1.0.0
      # @api private
      attr_reader :options

      # @since 1.0.0
      # @api private
      attr_reader :clock

      # @since 1.0.0
      # @api private
      attr_reader :on_crash

      # @since 1.0.0
      # @api private
      attr_reader :mutex

      # @since 1.0.0
      # @api private
      CRASH_LOGGER = ::Logger.new($stdout).tap { |logger|
        logger.formatter = -> (_, _, _, message) { "#{message}#{NEW_LINE}" }
        logger.level = FATAL
      }.freeze

      # @since 1.0.0
      # @api private
      ON_CRASH = -> (progname:, exception:, message:, payload:) {
        CRASH_LOGGER.fatal(Logger.templates[:crash] % {
          severity: "FATAL",
          progname: progname,
          time: Time.now,
          log_entry: [message, payload].map(&:to_s).reject(&:empty?).join(SEPARATOR),
          exception: exception.class,
          message: exception.message,
          backtrace: TAB + exception.backtrace.join(NEW_LINE + TAB)
        })
      }

      # Set up a dispatcher
      #
      # @since 1.0.0
      # @api private
      #
      # @return [Dispatcher]
      def self.setup(id, **options)
        dispatcher = new(id, **DEFAULT_OPTS, **options)
        yield(dispatcher) if block_given?
        dispatcher.add_backend if dispatcher.backends.empty?
        dispatcher
      end

      # @since 1.0.0
      # @api private
      def self.default_context
        Thread.current[:__dry_logger__] ||= {}
      end

      # @since 1.0.0
      # @api private
      def initialize(
        id, backends: [], tags: [], context: self.class.default_context, **options
      )
        @id = id
        @backends = backends
        @options = {**options, progname: id}
        @mutex = Mutex.new
        @context = context
        @tags = tags
        @clock = Clock.new(**(options[:clock] || EMPTY_HASH))
        @on_crash = options[:on_crash] || ON_CRASH
      end

      # Log an entry with UNKNOWN severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def unknown(message = nil, **payload)
        log(:unknown, message, **payload)
      end

      # Log an entry with DEBUG severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def debug(message = nil, **payload)
        log(:debug, message, **payload)
      end

      # Log an entry with INFO severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def info(message = nil, **payload)
        log(:info, message, **payload)
      end

      # Log an entry with WARN severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def warn(message = nil, **payload)
        log(:warn, message, **payload)
      end

      # Log an entry with ERROR severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def error(message = nil, **payload)
        log(:error, message, **payload)
      end

      # Log an entry with FATAL severity
      #
      # @see Dispatcher#log
      # @api public
      # @return [true]
      def fatal(message = nil, **payload)
        log(:fatal, message, **payload)
      end

      BACKEND_METHODS.each do |name|
        define_method(name) do
          forward(name)
        end
      end

      # Return severity level
      #
      # @since 1.0.0
      # @return [Integer]
      # @api public
      def level
        LEVELS[options[:level]]
      end

      # Pass logging to all configured backends
      #
      # @example logging a message
      #   logger.log(:info, "Hello World")
      #
      # @example logging payload
      #   logger.log(:info, verb: "GET", path: "/users")
      #
      # @example logging message and payload
      #   logger.log(:info, "User index request", verb: "GET", path: "/users")
      #
      # @example logging exception
      #   begin
      #     # things that may raise
      #   rescue => e
      #     logger.log(:error, e)
      #     raise e
      #   end
      #
      # @param [Symbol] severity The log severity name
      # @param [String] message Optional message
      # @param [Hash] payload Optional log entry payload
      #
      # @since 1.0.0
      # @return [true]
      # @api public
      def log(severity, message = nil, **payload)
        case message
        when Hash then log(severity, nil, **message)
        else
          entry = Entry.new(
            clock: clock,
            progname: id,
            severity: severity,
            tags: @tags,
            message: message,
            payload: {**context, **payload}
          )

          each_backend do |backend|
            backend.__send__(severity, entry) if backend.log?(entry)
          rescue StandardError => e
            on_crash.(progname: id, exception: e, message: message, payload: payload)
          end
        end

        true
      rescue StandardError => e
        on_crash.(progname: id, exception: e, message: message, payload: payload)
        true
      end

      # (EXPERIMENTAL) Tagged logging withing the provided block
      #
      # @example
      #   logger.tagged("red") do
      #     logger.info "Hello World"
      #     # Hello World tag=red
      #   end
      #
      #   logger.info "Hello Again"
      #   # Hello Again
      #
      # @since 1.0.0
      # @api public
      def tagged(*tags)
        @tags.concat(tags)
        yield
      ensure
        @tags = []
      end

      # Add a new backend to an existing dispatcher
      #
      # @example
      #   logger.add_backend(template: "ERROR: %<message>s") { |b|
      #     b.log_if = -> entry { entry.error? }
      #   }
      #
      # @since 1.0.0
      # @return [Dispatcher]
      # @api public
      def add_backend(instance = nil, **backend_options)
        backend =
          case (instance ||= Dry::Logger.new(**options, **backend_options))
          when Backends::Stream then instance
          else Backends::Proxy.new(instance, **options, **backend_options)
          end

        yield(backend) if block_given?

        backends << backend
        self
      end

      # @since 1.0.0
      # @api public
      def inspect
        %(#<#{self.class} id=#{id} options=#{options} backends=#{backends}>)
      end

      # @since 1.0.0
      # @api private
      def each_backend(&block)
        mutex.synchronize do
          backends.each(&block)
        end
      end

      # Pass logging to all configured backends
      #
      # @since 1.0.0
      # @return [true]
      # @api private
      def forward(meth, ...)
        each_backend { |backend| backend.public_send(meth, ...) }
        true
      end
    end
  end
end
