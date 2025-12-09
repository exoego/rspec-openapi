# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.2.0
          # @api private
          class Relation < Command
            argument :name, required: true, desc: "Relation name"
            option :gateway, desc: "Generate relation for gateway"

            example [
              %(books               (MyApp::Relation::Book)),
              %(books/drafts        (MyApp::Relations::Books::Drafts)),
              %(books --slice=admin (Admin::Relations::Books)),
              %(books --slice=admin --gateway=extra (Admin::Relations::Books)),
            ]

            # @since 2.2.0
            # @api private
            def generator_class
              Generators::App::Relation
            end

            def call(name:, slice: nil, gateway: nil)
              if slice
                generator.call(
                  key: name,
                  namespace: slice,
                  base_path: fs.join("slices", inflector.underscore(slice)),
                  gateway: gateway
                )
              else
                generator.call(
                  key: name,
                  namespace: app.namespace,
                  base_path: "app",
                  gateway: gateway
                )
              end
            end
          end
        end
      end
    end
  end
end
