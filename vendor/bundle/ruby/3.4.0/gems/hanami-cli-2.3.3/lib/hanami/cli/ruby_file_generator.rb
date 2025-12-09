# frozen_string_literal: true

require "ripper"

module Hanami
  module CLI
    class RubyFileGenerator
      # @api private
      # @since 2.2.0
      class GeneratedUnparseableCodeError < Error
        def initialize(source_code)
          super(
            <<~ERROR_MESSAGE
              Sorry, the code we generated is not valid Ruby.

              Here's what we got:

              #{source_code}

              Please fix the errors and try again.
            ERROR_MESSAGE
          )
        end
      end

      INDENT = "  "

      def self.class(class_name, **args)
        new(class_name: class_name, **args).call
      end

      def self.module(*names, **args)
        module_names = if names.first.is_a?(Array)
                         names.first
                       else
                         names
                       end

        new(
          modules: module_names,
          class_name: nil,
          parent_class_name: nil,
          **args,
        ).call
      end

      def initialize(
        class_name: nil,
        parent_class_name: nil,
        modules: [],
        header: [],
        body: []
      )
        @class_name = class_name
        @parent_class_name = parent_class_name
        @modules = modules
        @header = header.any? ? (header + [""]) : []
        @body = body

        if parent_class_name && !class_name
          raise ArgumentError, "class_name is required when parent_class_name is specified"
        end
      end

      def call
        definition = lines(modules).map { |line| "#{line}\n" }.join
        source_code = [header, definition].flatten.join("\n")
        ensure_parseable!(source_code)
        source_code
      end

      private

      attr_reader(
        :class_name,
        :parent_class_name,
        :modules,
        :header,
        :body
      )

      def lines(remaining_modules)
        this_module, *rest_modules = remaining_modules
        if this_module
          with_module_lines(this_module, lines(rest_modules))
        elsif class_name
          class_lines
        else
          body
        end
      end

      def with_module_lines(module_name, contents_lines)
        [
          "module #{module_name}",
          *contents_lines.map { |line| indent(line) },
          "end"
        ]
      end

      def class_lines
        [
          class_definition,
          *body.map { |line| indent(line) },
          "end"
        ].compact
      end

      def class_definition
        if parent_class_name
          "class #{class_name} < #{parent_class_name}"
        else
          "class #{class_name}"
        end
      end

      def indent(line)
        if line.strip.empty?
          ""
        else
          INDENT + line
        end
      end

      def ensure_parseable!(source_code)
        unless Ripper.sexp(source_code)
          raise GeneratedUnparseableCodeError.new(source_code)
        end
      end
    end
  end
end
