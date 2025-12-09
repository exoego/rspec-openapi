# frozen_string_literal: true

require "erb"
require "dry/files"

module Hanami
  module CLI
    module Generators
      module App
        # @since 2.0.0
        # @api private
        class Slice
          # @since 2.0.0
          # @api private
          def initialize(fs:, inflector:)
            @fs = fs
            @inflector = inflector
          end

          # @since 2.0.0
          # @api private
          def call(app, slice, url, **opts)
            skip_route = opts.fetch(:skip_route, false)

            unless skip_route
              fs.inject_line_at_class_bottom(
                fs.join("config", "routes.rb"),
                "class Routes",
                <<~ROUTES.chomp

                  slice :#{inflector.underscore(slice)}, at: "#{url}" do
                  end
                ROUTES
              )
            end

            fs.mkdir(directory = "slices/#{slice}")

            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: slice,
              key: "action",
              base_path: directory,
              parent_class_name: "#{Hanami.app.namespace}::Action",
              auto_register: false
            ).create

            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: slice,
              key: "view",
              base_path: directory,
              parent_class_name: "#{Hanami.app.namespace}::View",
              auto_register: false
            ).create

            RubyModuleFile.new(
              fs: fs,
              inflector: inflector,
              namespace: slice,
              key: "views.helpers",
              base_path: directory,
              auto_register: false,
              body: ["# Add your view helpers here"]
            ).create

            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: slice,
              key: "views.context",
              base_path: directory,
              parent_class_name: "#{Hanami.app.namespace}::View::Context",
              auto_register: false,
              body: ["# Define your view context here. See https://guides.hanamirb.org/views/context/ for details."]
            ).create

            fs.create(
              fs.join(directory, "templates", "layouts", "app.html.erb"),
              app_layout_template(
                page_title: "#{inflector.humanize(app)} - #{inflector.humanize(slice)}"
              )
            )

            if Hanami.bundled?("dry-operation")
              RubyClassFile.new(
                fs: fs,
                inflector: inflector,
                namespace: slice,
                key: "operation",
                base_path: directory,
                parent_class_name: "#{Hanami.app.namespace}::Operation",
                auto_register: false
              ).create
            end

            if Hanami.bundled?("hanami-assets")
              fs.create(
                fs.join(directory, "assets", "js", "app.js"),
                %(import "../css/app.css";\n)
              )
              fs.create(
                fs.join(directory, "assets", "css", "app.css"),
                <<~CSS
                  body {
                    background-color: #fff;
                    color: #000;
                    font-family: sans-serif;
                  }
                CSS
              )
              fs.create(fs.join(directory, "assets", "images", "favicon.ico"), file("favicon.ico"))
            end

            if Hanami.bundled?("hanami-db") && !opts.fetch(:skip_db, false)
              RubyClassFile.new(
                fs: fs,
                inflector: inflector,
                namespace: slice,
                key: "db.relation",
                base_path: directory,
                parent_class_name: "#{Hanami.app.namespace}::DB::Relation",
              ).create

              RubyClassFile.new(
                fs: fs,
                inflector: inflector,
                namespace: slice,
                key: "db.repo",
                base_path: directory,
                parent_class_name: "#{Hanami.app.namespace}::DB::Repo",
              ).create

              RubyClassFile.new(
                fs: fs,
                inflector: inflector,
                namespace: slice,
                key: "db.struct",
                base_path: directory,
                parent_class_name: "#{Hanami.app.namespace}::DB::Struct",
              ).create

              fs.touch(fs.join(directory, "relations", ".keep"))
              fs.touch(fs.join(directory, "repos", ".keep"))
              fs.touch(fs.join(directory, "structs", ".keep"))
            end

            fs.touch(fs.join(directory, "actions/.keep"))
            fs.touch(fs.join(directory, "views/.keep"))
            fs.touch(fs.join(directory, "templates/.keep"))
            fs.touch(fs.join(directory, "templates/layouts/.keep"))
          end

          private

          attr_reader :fs

          attr_reader :inflector

          def file(path)
            File.read(File.join(__dir__, "slice", path))
          end

          def app_layout_template(page_title:)
            bundled_assets = Hanami.bundled?("hanami-assets")

            <<~LAYOUT
              <!DOCTYPE html>
              <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>#{page_title}</title>
                  #{'<%= favicon_tag %>' if bundled_assets}
                  #{'<%= stylesheet_tag "app" %>' if bundled_assets}
                </head>
                <body>
                  <%= yield %>
                  #{'<%= javascript_tag "app" %>' if bundled_assets}
                </body>
              </html>
            LAYOUT
          end
        end
      end
    end
  end
end
