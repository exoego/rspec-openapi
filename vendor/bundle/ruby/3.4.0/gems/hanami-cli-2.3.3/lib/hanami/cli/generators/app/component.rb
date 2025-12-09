# frozen_string_literal: true

require "erb"
require "dry/files"

module Hanami
  module CLI
    module Generators
      module App
        # @api private
        # @since 2.2.0
        class Component
          # @api private
          # @since 2.2.0
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
          end

          # @api private
          # @since 2.2.0
          def call(key:, namespace:, base_path:)
            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              key: key,
              namespace: namespace,
              base_path: base_path,
            ).create
          end

          private

          attr_reader :fs, :inflector, :out
        end
      end
    end
  end
end
