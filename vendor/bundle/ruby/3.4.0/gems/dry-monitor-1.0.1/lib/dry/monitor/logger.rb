# frozen_string_literal: true

require "logger"

module Dry
  module Monitor
    class Logger < ::Logger
      DEFAULT_FORMATTER = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end

      def initialize(*args)
        super
        self.formatter = DEFAULT_FORMATTER
      end
    end
  end
end
