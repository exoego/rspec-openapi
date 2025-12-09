# frozen_string_literal: true

require "erb"
require "shellwords"

module Hanami
  module CLI
    module Generators
      # @since 2.0.0
      # @api private
      module Gem
        # @since 2.0.0
        # @api private
        class App
          # @since 2.0.0
          # @api private
          def initialize(fs:, inflector:)
            super()
            @fs = fs
            @inflector = inflector
          end

          # @since 2.0.0
          # @api private
          def call(app, context: Context.new(inflector, app), &blk)
            generate_app(app, context)
            blk.call
          end

          private

          attr_reader :fs

          attr_reader :inflector

          def generate_app(app, context) # rubocop:disable Metrics/AbcSize
            fs.create(".gitignore", t("gitignore.erb", context))
            fs.create(".env", t("env.erb", context))

            fs.create("README.md", t("readme.erb", context))
            fs.create("Gemfile", t("gemfile.erb", context))
            fs.create("Rakefile", t("rakefile.erb", context))
            fs.create("Procfile.dev", t("procfile.erb", context))
            fs.create("config.ru", t("config_ru.erb", context))

            fs.create("bin/dev", file("dev"))
            fs.chmod("bin/dev", 0o755)

            fs.create("bin/setup", t("setup.erb", context))
            fs.chmod("bin/setup", 0o755)

            fs.create("config/app.rb", t("app.erb", context))
            fs.create("config/settings.rb", t("settings.erb", context))
            fs.create("config/routes.rb", t("routes.erb", context))
            fs.create("config/puma.rb", t("puma.erb", context))

            fs.create("lib/tasks/.keep", t("keep.erb", context))
            fs.create("lib/#{app}/types.rb", t("types.erb", context))

            fs.create("app/actions/.keep", t("keep.erb", context))
            fs.create("app/action.rb", t("action.erb", context))

            if context.generate_view?
              fs.create("app/view.rb", t("view.erb", context))
              fs.create("app/views/helpers.rb", t("helpers.erb", context))
              fs.create("app/views/context.rb", t("context.erb", context))
              fs.create("app/templates/layouts/app.html.erb", t("app_layout.erb", context))

              fs.create("public/404.html", file("404.html"))
              fs.create("public/500.html", file("500.html"))
            end

            if context.generate_assets?
              fs.create("package.json", t("package.json.erb", context))
              fs.create("config/assets.js", file("assets.js"))
              fs.create("app/assets/js/app.js", t("app_js.erb", context))
              fs.create("app/assets/css/app.css", t("app_css.erb", context))
              fs.create("app/assets/images/favicon.ico", file("favicon.ico"))
            end

            if context.generate_db?
              fs.create("app/db/relation.rb", t("relation.erb", context))
              fs.create("app/relations/.keep", t("keep.erb", context))

              fs.create("app/db/repo.rb", t("repo.erb", context))
              fs.create("app/repos/.keep", t("keep.erb", context))

              fs.create("app/db/struct.rb", t("struct.erb", context))
              fs.create("app/structs/.keep", t("keep.erb", context))

              fs.create("config/db/seeds.rb", t("seeds.erb", context))
              fs.create("config/db/migrate/.keep", t("keep.erb", context))

              if context.generate_sqlite?
                fs.create("db/.keep", t("keep.erb", context))
              end
            end

            fs.create("app/operation.rb", t("operation.erb", context))
          end

          def template(path, context)
            require "erb"

            ERB.new(
              File.read(File.join(__dir__, "app", path)),
              trim_mode: "-"
            ).result(context.ctx)
          end

          alias_method :t, :template

          def file(path)
            File.read(File.join(__dir__, "app", path))
          end
        end
      end
    end
  end
end
