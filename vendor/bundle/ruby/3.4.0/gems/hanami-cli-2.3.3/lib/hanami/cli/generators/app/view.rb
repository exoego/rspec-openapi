# frozen_string_literal: true

require "dry/files"
require_relative "../constants"
require_relative "../../errors"

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.0.0
        # @api private
        class View
          DEFAULT_FORMAT = "html"
          private_constant :DEFAULT_FORMAT

          TEMPLATES_FOLDER = "templates"
          private_constant :TEMPLATES_FOLDER

          # @since 2.0.0
          # @api private
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
          end

          # @since 2.0.0
          # @api private
          def call(key:, namespace:, base_path:)
            view_class_file(key:, namespace:, base_path:).then do |view_class|
              view_class.create
              view_class_name = view_class.fully_qualified_name
              create_template_file(key:, base_path:, view_class_name:)
            end
          end

          private

          attr_reader :fs, :inflector, :out

          def view_class_file(key:, namespace:, base_path:)
            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: namespace,
              key: key,
              base_path: base_path,
              parent_class_name: "#{inflector.camelize(namespace)}::View",
              extra_namespace: "Views",
            )
          end

          def create_template_file(key:, base_path:, view_class_name:)
            key_parts = key.split(KEY_SEPARATOR)
            class_name_from_key = key_parts.pop # takes last segment as the class name
            module_names_from_key = key_parts # the rest of the segments are the module names

            file_path = fs.join(
              base_path,
              TEMPLATES_FOLDER,
              module_names_from_key,
              template_file_name(class_name_from_key, DEFAULT_FORMAT),
            )
            body = "<h1>#{view_class_name}</h1>\n"
            fs.create(file_path, body)
          end

          def template_file_name(name, format)
            ext =
              case format.to_sym
              when :html
                ".html.erb"
              else
                ".erb"
              end

            "#{name}#{ext}"
          end
        end
      end
    end
  end
end
