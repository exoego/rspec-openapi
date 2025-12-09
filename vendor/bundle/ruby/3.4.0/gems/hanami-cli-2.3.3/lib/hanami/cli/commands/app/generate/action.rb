# frozen_string_literal: true

require "dry/inflector"
require "dry/files"
require "shellwords"
require_relative "../../../naming"
require_relative "../../../errors"

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.0.0
          # @api private
          class Action < Command
            # TODO: ideally the default format should lookup
            #       slice configuration (Action's `default_response_format`)
            DEFAULT_FORMAT = "html"
            private_constant :DEFAULT_FORMAT

            DEFAULT_SKIP_VIEW = false
            private_constant :DEFAULT_SKIP_VIEW

            DEFAULT_SKIP_TESTS = false
            private_constant :DEFAULT_SKIP_TESTS

            DEFAULT_SKIP_ROUTE = false
            private_constant :DEFAULT_SKIP_ROUTE

            argument :name, required: true, desc: "Action name"

            option :url, as: :url_path, required: false, type: :string, desc: "Action URL path"

            option :http, as: :http_method, required: false, type: :string, desc: "Action HTTP method"

            option \
              :skip_view,
              required: false,
              type: :flag,
              default: DEFAULT_SKIP_VIEW,
              desc: "Skip view and template generation"

            option \
              :skip_tests,
              required: false,
              type: :flag,
              default: DEFAULT_SKIP_TESTS,
              desc: "Skip test generation"

            option \
              :skip_route,
              required: false,
              type: :flag,
              default: DEFAULT_SKIP_ROUTE,
              desc: "Skip route generation"

            option :slice, required: false, desc: "Slice name"

            # option :format, required: false, type: :string, default: DEFAULT_FORMAT, desc: "Template format"

            example [
              %(books.index               # GET    /books          to: "books.index"    (MyApp::Actions::Books::Index)),
              %(books.new                 # GET    /books/new      to: "books.new"      (MyApp::Actions::Books::New)),
              %(books.create              # POST   /books          to: "books.create"   (MyApp::Actions::Books::Create)),
              %(books.edit                # GET    /books/:id/edit to: "books.edit"     (MyApp::Actions::Books::Edit)),
              %(books.update              # PATCH  /books/:id      to: "books.update"   (MyApp::Actions::Books::Update)),
              %(books.show                # GET    /books/:id      to: "books.show"     (MyApp::Actions::Books::Show)),
              %(books.destroy             # DELETE /books/:id      to: "books.destroy"  (MyApp::Actions::Books::Destroy)),
              %(books.sale                # GET    /books/sale     to: "books.sale"     (MyApp::Actions::Books::Sale)),
              %(sessions.new --url=/login # GET    /login          to: "sessions.new"   (MyApp::Actions::Sessions::New)),
              %(authors.update --http=put # PUT    /authors/:id    to: "authors.update" (MyApp::Actions::Authors::Update)),
              %(users.index --slice=admin # GET    /admin/users    to: "users.index"    (Admin::Actions::Users::Update))
            ]
            def generator_class
              Generators::App::Action
            end

            # @since 2.0.0
            # @api private
            # rubocop:disable Metrics/ParameterLists
            def call(
              name:,
              slice: nil,
              url_path: nil,
              http_method: nil,
              skip_view: DEFAULT_SKIP_VIEW,
              skip_route: DEFAULT_SKIP_ROUTE,
              skip_tests: DEFAULT_SKIP_TESTS
            )
              name = Naming.new(inflector:).action_name(name)

              raise InvalidActionNameError.new(name) unless name.include?(".")

              super(
                name: name,
                slice: slice,
                url_path: url_path,
                skip_route: skip_route,
                http_method: http_method,
                skip_view: skip_view || !Hanami.bundled?("hanami-view"),
                skip_tests: skip_tests
              )
            end
            # rubocop:enable Metrics/ParameterLists
          end
        end
      end
    end
  end
end
