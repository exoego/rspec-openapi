# frozen_string_literal: true

require "pry"
require_relative "core"

module Hanami
  module CLI
    module Repl
      # @since 2.0.0
      # @api private
      class Pry < Core
        class Context
        end

        def start
          ::Pry.config.prompt = ::Pry::Prompt.new(
            "hanami",
            "my custom prompt",
            [proc { |*| "#{prompt}> " }]
          )

          ::Pry.start(Context.new.extend(context))
        end
      end
    end
  end
end
