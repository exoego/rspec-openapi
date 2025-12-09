# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.2.0
          # @api private
          class Operation < Command
            argument :name, required: true, desc: "Operation name"

            example [
              %(books.add               (MyApp::Books::Add)),
              %(books.add --slice=admin (Admin::Books::Add)),
            ]

            def generator_class
              Generators::App::Operation
            end
          end
        end
      end
    end
  end
end
