# frozen_string_literal: true

require "stringio"

module Dry
  module Logger
    # Global setup methods
    #
    # @api public
    module Global
      # Register a new formatter
      #
      # @example
      #   class MyFormatter < Dry::Logger::Formatters::Structured
      #     def format_message(value)
      #       "WOAH: #{message}"
      #     end
      #
      #     def format_time(value)
      #       Time.now.strftime("%Y-%m-%d %H:%M:%S")
      #     end
      #   end
      #
      #   Dry::Logger.register_formatter(:my_formatter, MyFormatter)
      #
      #   logger = Dry.Logger(:app, formatter: :my_formatter, template: :details)
      #
      #   logger.info "Hello World"
      #   # [test] [INFO] [2022-11-15 10:06:29] WOAH: Hello World
      #
      # @since 1.0.0
      # @return [Hash]
      # @api public
      def register_formatter(name, formatter)
        formatters[name] = formatter
        formatters
      end

      # Register a new template
      #
      # @example basic template
      #   Dry::Logger.register_template(:request, "[%<severity>s] %<verb>s %<path>s")
      #
      #   logger = Dry.Logger(:my_app, template: :request)
      #
      #   logger.info(verb: "GET", path: "/users")
      #   # [INFO] GET /users
      #
      # @example template with colors
      #   Dry::Logger.register_template(
      #     :request, "[%<severity>s] <green>%<verb>s</green> <blue>%<path>s</blue>"
      #   )
      #
      # @since 1.0.0
      # @return [Hash]
      # @api public
      def register_template(name, template)
        templates[name] = template
        templates
      end

      # Build a logging backend instance
      #
      # @since 1.0.0
      # @return [Backends::Stream]
      # @api private
      def new(stream: $stdout, **options)
        backend =
          case stream
          when IO, StringIO then Backends::IO
          when String, Pathname then Backends::File
          else
            raise ArgumentError, "unsupported stream type #{stream.class}"
          end

        formatter_spec = options[:formatter]
        template_spec = options[:template]

        template =
          case template_spec
          when Symbol then templates.fetch(template_spec)
          when String then template_spec
          when nil then templates[:default]
          else
            raise ArgumentError,
                  ":template option must be a Symbol or a String (`#{template_spec}` given)"
          end

        formatter_options = {**options, template: template}

        formatter =
          case formatter_spec
          when Symbol then formatters.fetch(formatter_spec).new(**formatter_options)
          when Class then formatter_spec.new(**formatter_options)
          when nil then formatters[:string].new(**formatter_options)
          when ::Logger::Formatter then formatter_spec
          else
            raise ArgumentError, "Unsupported formatter option #{formatter_spec.inspect}"
          end

        backend_options = options.select { |key, _| BACKEND_OPT_KEYS.include?(key) }

        backend.new(stream: stream, **backend_options, formatter: formatter)
      end

      # Internal formatters registry
      #
      # @since 1.0.0
      # @api private
      def formatters
        @formatters ||= {}
      end

      # Internal templates registry
      #
      # @since 1.0.0
      # @api private
      def templates
        @templates ||= {}
      end
    end
  end
end
