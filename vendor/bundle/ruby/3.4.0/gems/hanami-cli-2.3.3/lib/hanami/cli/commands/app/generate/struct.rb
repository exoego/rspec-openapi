# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.2.0
          # @api private
          class Struct < Command
            argument :name, required: true, desc: "Struct name"

            example [
              %(book                (MyApp::Structs::Book)),
              %(book/published_book (MyApp::Structs::Book::PublishedBook)),
              %(book --slice=admin  (Admin::Structs::Book)),
            ]

            def generator_class
              Generators::App::Struct
            end
          end
        end
      end
    end
  end
end
