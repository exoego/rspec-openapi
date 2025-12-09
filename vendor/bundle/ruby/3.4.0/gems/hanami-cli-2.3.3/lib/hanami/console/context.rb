# frozen_string_literal: true

require_relative "plugins/slice_readers"
require_relative "plugins/unbooted_slice_warnings"

module Hanami
  # @since 2.0.0
  # @api private
  module Console
    # Hanami app console context
    #
    # @since 2.0.0
    # @api private
    class Context < Module
      attr_reader :app

      # @since 2.0.0
      # @api private
      def initialize(app)
        super()
        @app = app

        define_context_methods
        include Plugins::SliceReaders.new(app)

        Plugins::UnbootedSliceWarnings.activate
      end

      private

      def define_context_methods
        hanami_app = app

        define_method(:inspect) do
          "#<#{self.class} app=#{hanami_app} env=#{hanami_app.config.env}>"
        end

        define_method(:app) do
          hanami_app
        end

        define_method(:reload) do
          puts "Reloading..."
          Kernel.exec("#{$PROGRAM_NAME} console")
        end

        define_method(:method_missing) do |name, *args, &block|
          return hanami_app.public_send(name, *args, &block) if hanami_app.respond_to?(name)

          super(name, *args, &block)
        end

        define_method(:respond_to_missing?) do |name, include_private|
          super(name, include_private) || hanami_app.respond_to?(name, include_private)
        end

        # User-provided extension modules
        app.config.console.extensions.each do |mod|
          include mod
        end
      end
    end
  end
end
