# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.2.0
          # @api private
          class Migration < Command
            argument :name, required: true, desc: "Migration name"
            option :gateway, desc: "Generate migration for gateway"

            example [
              %(create_posts),
              %(add_published_at_to_posts),
              %(create_users --slice=admin),
              %(create_comments --slice=admin --gateway=extra),
            ]

            def generator_class
              Generators::App::Migration
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
