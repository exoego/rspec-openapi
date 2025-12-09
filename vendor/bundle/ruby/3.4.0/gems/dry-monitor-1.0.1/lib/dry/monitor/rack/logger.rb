# frozen_string_literal: true

require "dry/monitor/rack/middleware"

module Dry
  module Monitor
    module Rack
      class Logger
        extend Dry::Configurable

        setting :filtered_params, default: %w[_csrf password]

        REQUEST_METHOD = "REQUEST_METHOD"
        PATH_INFO = "PATH_INFO"
        REMOTE_ADDR = "REMOTE_ADDR"
        QUERY_STRING = "QUERY_STRING"

        START_MSG = %(Started %s "%s" for %s at %s)
        STOP_MSG = %(Finished %s "%s" for %s in %s [Status: %s]\n)
        QUERY_MSG = %(  Query parameters )
        FILTERED = "[FILTERED]"

        attr_reader :logger, :config

        def initialize(logger, config = self.class.config)
          @logger = logger
          @config = config
        end

        def attach(rack_monitor)
          rack_monitor.on(:start) { |params| log_start_request(params[:env]) }
          rack_monitor.on(:stop) { |params| log_stop_request(**params) }
          rack_monitor.on(:error) { |event| log_exception(event[:exception]) }
        end

        def log_exception(err)
          logger.error err.message
          logger.error filter_backtrace(err.backtrace).join("\n")
        end

        def log_start_request(request)
          logger.info START_MSG % [
            request[REQUEST_METHOD],
            request[PATH_INFO],
            request[REMOTE_ADDR],
            Time.now
          ]
          log_request_params(request)
        end

        def log_stop_request(env:, status:, time:)
          logger.info STOP_MSG % [
            env[REQUEST_METHOD],
            env[PATH_INFO],
            env[REMOTE_ADDR],
            time,
            status
          ]
        end

        def log_request_params(request)
          with_http_params(request[QUERY_STRING]) do |params|
            logger.info QUERY_MSG + params.inspect
          end
        end

        def info(*args)
          logger.info(*args)
        end

        def with_http_params(params)
          params = ::Rack::Utils.parse_nested_query(params)

          yield(filter_params(params)) unless params.empty?
        end

        def filter_backtrace(backtrace)
          # TODO: what do we want to do with this?
          backtrace.reject { |l| l.include?("gems") }
        end

        def filter_params(params)
          params.each do |k, v|
            if config.filtered_params.include?(k)
              params[k] = FILTERED
            elsif v.is_a?(Hash)
              filter_params(v)
            elsif v.is_a?(Array)
              v.map! { |m| m.is_a?(Hash) ? filter_params(m) : m }
            end
          end

          params
        end
      end
    end
  end
end
