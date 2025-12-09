# frozen_string_literal: true

require_relative "../constants"

module Hanami
  module CLI
    module Generators
      module App
        # @api private
        class RubyFile
          def initialize(
            fs:,
            inflector:,
            key:,
            namespace:,
            base_path:,
            extra_namespace: nil,
            auto_register: nil,
            body: [],
            **_opts
          )
            @fs = fs
            @inflector = inflector
            @key_segments = key.split(KEY_SEPARATOR).map { |segment| inflector.underscore(segment) }
            @namespace = namespace
            @base_path = base_path
            @extra_namespace = extra_namespace&.downcase
            @auto_register = auto_register
            @body = body
          end

          # @api private
          def create
            fs.create(path, file_contents)
          end

          # @api private
          def write
            fs.write(path, file_contents)
          end

          # @api private
          def fully_qualified_name
            inflector.camelize(
              [namespace, extra_namespace, *key_segments].join("/"),
            )
          end

          # @api private
          def path
            fs.join(directory, "#{key_segments.last}.rb")
          end

          private

          # @api private
          attr_reader(
            :fs,
            :inflector,
            :key_segments,
            :base_path,
            :namespace,
            :extra_namespace,
            :auto_register,
            :body,
          )

          # @api private
          def file_contents
            RubyFileGenerator.new(
              # These first three must be implemented by subclasses
              class_name: class_name,
              parent_class_name: parent_class_name,
              modules: modules,
              header: headers,
              body: body
            ).call
          end

          # @api private
          def local_namespaces
            Array(extra_namespace) + key_segments[..-2]
          end

          # @api private
          def namespace_modules
            [namespace, *local_namespaces]
              .map { normalize(_1) }
              .compact
          end

          # @api private
          def directory
            @directory ||= if local_namespaces.any?
                             fs.join(base_path, local_namespaces)
                           else
                             base_path
                           end
          end

          # @api private
          def constant_name
            normalize(key_segments.last)
          end

          # @api private
          def headers
            [
              # Intentional ternary logic. Skip if nil, else 'true' or 'false'
              ("# auto_register: #{auto_register}" unless auto_register.nil?),
              "# frozen_string_literal: true",
            ].compact
          end

          # @api private
          def normalize(name)
            inflector.camelize(name).gsub(/[^\p{Alnum}]/, "")
          end
        end
      end
    end
  end
end
