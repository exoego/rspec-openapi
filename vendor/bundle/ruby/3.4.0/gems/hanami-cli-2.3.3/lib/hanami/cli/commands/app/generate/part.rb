# frozen_string_literal: true

require "dry/inflector"
require "dry/files"
require "shellwords"

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.1.0
          # @api private
          class Part < Command
            DEFAULT_SKIP_TESTS = false
            private_constant :DEFAULT_SKIP_TESTS

            argument :name, required: true, desc: "Part name"

            option \
              :skip_tests,
              required: false,
              type: :flag,
              default: DEFAULT_SKIP_TESTS,
              desc: "Skip test generation"

            example [
              %(book               (MyApp::Views::Parts::Book)),
              %(book --slice=admin (Admin::Views::Parts::Book)),
            ]

            def generator_class
              Generators::App::Part
            end
          end
        end
      end
    end
  end
end
