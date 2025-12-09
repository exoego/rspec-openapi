# frozen_string_literal: true

require "erb"
require "dry/files"

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.1.0
        # @api private
        class Part
          # @since 2.1.0
          # @api private
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
          end

          # @since 2.1.0
          # @api private
          def call(key:, namespace:, base_path:, **)
            create_app_base_part_if_missing(key:, namespace:, base_path:)
            create_slice_part_if_missing(key:, namespace:, base_path:) unless namespace == Hanami.app.namespace
            create_generated_part(key:, namespace:, base_path:)
          end

          private

          # @since 2.1.0
          # @api private
          attr_reader :fs, :inflector, :out

          def create_app_base_part_if_missing(key:, namespace:, base_path:)
            return if fs.exist?(fs.join(base_path, "views", "part.rb"))

            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: Hanami.app.namespace,
              key: "views.part",
              base_path: APP_DIR,
              parent_class_name: "Hanami::View::Part",
              auto_register: false
            ).create
          end

          def create_slice_part_if_missing(key:, namespace:, base_path:)
            return if fs.exist?(fs.join(base_path, "views", "part.rb"))

            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: namespace,
              key: "views.part",
              base_path: base_path,
              parent_class_name: "#{Hanami.app.namespace}::Views::Part",
              auto_register: false
            ).create
          end

          def create_generated_part(key:, namespace:, base_path:)
            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: namespace,
              key: inflector.underscore("views.parts.#{key}"),
              base_path: base_path,
              parent_class_name: "#{inflector.camelize(namespace)}::Views::Part",
              auto_register: false
            ).create
          end
        end
      end
    end
  end
end
