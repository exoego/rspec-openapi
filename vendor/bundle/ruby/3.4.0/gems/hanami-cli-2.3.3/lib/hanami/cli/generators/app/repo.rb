# frozen_string_literal: true

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.2.0
        # @api private
        class Repo
          # @since 2.2.0
          # @api private
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
          end

          # @since 2.2.0
          # @api private
          def call(key:, namespace:, base_path:)
            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              key: key,
              namespace: namespace,
              base_path: base_path,
              extra_namespace: "Repos",
              parent_class_name: "#{inflector.camelize(namespace)}::DB::Repo",
            ).create
          end

          private

          attr_reader :fs, :inflector, :out
        end
      end
    end
  end
end
