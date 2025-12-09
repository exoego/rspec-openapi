# frozen_string_literal: true

require "dry/inflector"
require "dry/files"
require "shellwords"

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @api private
          # @since 2.2.0
          class Component < Command
            argument :name, required: true, desc: "Component name"

            example [
              %(isbn_decoder               (MyApp::IsbnDecoder)),
              %(recommenders.fiction       (MyApp::Recommenders::Fiction)),
              %(isbn_decoder --slice=admin (Admin::IsbnDecoder)),
              %(Exporters::Complete::CSV   (MyApp::Exporters::Complete::CSV)),
            ]

            # @since 2.2.0
            # @api private
            def generator_class
              Generators::App::Component
            end
          end
        end
      end
    end
  end
end
