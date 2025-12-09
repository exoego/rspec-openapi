# frozen_string_literal: true

require "hanami/console/context"
require_relative "../errors"

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    module Repl
      # @since 2.0.0
      # @api private
      class Core
        attr_reader :app
        attr_reader :opts

        # @since 2.0.0
        # @api private
        def initialize(app, opts)
          @app = app
          @opts = opts
        end

        # @since 2.0.0
        # @api private
        def start
          raise Hanami::CLI::NotImplementedError
        end

        # @since 2.0.0
        # @api private
        def context
          @context ||= Hanami::Console::Context.new(app)
        end

        # @since 2.0.0
        # @api private
        def prompt
          "#{name}[#{env}]"
        end

        # @since 2.0.0
        # @api private
        def name
          (app.container.config.name || inflector.underscore(app.name))
            .to_s.split("/")[0]
        end

        # @since 2.0.0
        # @api private
        def env
          app.container.env
        end

        # @since 2.0.0
        # @api private
        def inflector
          app.inflector
        end
      end
    end
  end
end
