# frozen_string_literal: true

require "dry/files"
require_relative "../constants"
require_relative "../../errors"

# rubocop:disable Metrics/ParameterLists
module Hanami
  module CLI
    module Generators
      module App
        # @since 2.0.0
        # @api private
        class Action
          # @since 2.0.0
          # @api private
          def initialize(fs:, inflector:, out: $stdout)
            @fs = fs
            @inflector = inflector
            @out = out
            @view_generator = Generators::App::View.new(
              fs: fs,
              inflector: inflector,
              out: out
            )
          end

          # @since 2.0.0
          # @api private
          def call(key:, namespace:, base_path:, url_path:, http_method:, skip_view:, skip_route:, skip_tests:)
            insert_route(key:, namespace:, url_path:, http_method:) unless skip_route

            generate_action(key: key, namespace: namespace, base_path: base_path, include_placeholder_body: skip_view)

            generate_view(key:, namespace:, base_path:) unless skip_view
          end

          private

          ROUTE_HTTP_METHODS = %w[get post delete put patch trace options link unlink].freeze
          private_constant :ROUTE_HTTP_METHODS

          ROUTE_DEFAULT_HTTP_METHOD = "get"
          private_constant :ROUTE_DEFAULT_HTTP_METHOD

          ROUTE_RESTFUL_HTTP_METHODS = {
            "create" => "post",
            "update" => "patch",
            "destroy" => "delete"
          }.freeze
          private_constant :ROUTE_RESTFUL_HTTP_METHODS

          ROUTE_RESTFUL_URL_SUFFIXES = {
            "index" => [],
            "new" => ["new"],
            "create" => [],
            "edit" => [":id", "edit"],
            "update" => [":id"],
            "show" => [":id"],
            "destroy" => [":id"]
          }.freeze
          private_constant :ROUTE_RESTFUL_URL_SUFFIXES

          # @api private
          # @since 2.1.0
          RESTFUL_COUNTERPART_VIEWS = {
            "create" => "new",
            "update" => "edit"
          }.freeze
          private_constant :RESTFUL_COUNTERPART_VIEWS

          PATH_SEPARATOR = "/"
          private_constant :PATH_SEPARATOR

          attr_reader :fs, :inflector, :out, :view_generator

          # @api private
          # @since 2.2.2
          def insert_route(key:, namespace:, url_path:, http_method:)
            routes_location = fs.join("config", "routes.rb")
            route = route_definition(key:, url_path:, http_method:)

            if namespace == Hanami.app.namespace
              fs.inject_line_at_class_bottom(routes_location, "class Routes", route)
            else
              slice_routes = fs.join("slices", namespace, "config", "routes.rb")

              if fs.exist?(slice_routes)
                fs.inject_line_at_class_bottom(slice_routes, "class Routes", route)
              else
                slice_matcher = /slice[[:space:]]*:#{namespace}/
                fs.inject_line_at_block_bottom(routes_location, slice_matcher, route)
              end
            end
          end

          # @api private
          # @since 2.2.2
          def generate_action(key:, namespace:, base_path:, include_placeholder_body:)
            RubyClassFile.new(
              fs: fs,
              inflector: inflector,
              namespace: namespace,
              key: key,
              base_path: base_path,
              parent_class_name: "#{inflector.camelize(namespace)}::Action",
              extra_namespace: "Actions",
              body: [
                "def handle(request, response)",
                ("  response.body = self.class.name" if include_placeholder_body),
                "end"
              ].compact
            ).create
          end

          # @api private
          # @since 2.2.2
          def generate_view(key:, namespace:, base_path:)
            *controller_name_parts, action_name = key.split(KEY_SEPARATOR)

            view_directory = fs.join(base_path, "views", controller_name_parts)

            if generate_view?(action_name, view_directory)
              view_generator.call(
                key: key,
                namespace: namespace,
                base_path: base_path,
              )
            end
          end

          # @api private
          # @since 2.2.2
          def route_definition(key:, url_path:, http_method:)
            *controller_name_parts, action_name = key.split(KEY_SEPARATOR)

            method = route_http(action_name, http_method)
            path = route_url(controller_name_parts, action_name, url_path)

            %(#{method} "#{path}", to: "#{key}")
          end

          # @api private
          # @since 2.1.0
          def generate_view?(action_name, directory)
            if rest_view?(action_name)
              generate_restful_view?(action_name, directory)
            else
              true
            end
          end

          # @api private
          # @since 2.1.0
          def generate_restful_view?(view, directory)
            corresponding_action = corresponding_restful_view(view)

            !fs.exist?(fs.join(directory, "#{corresponding_action}.rb"))
          end

          # @api private
          # @since 2.1.0
          def rest_view?(view)
            RESTFUL_COUNTERPART_VIEWS.keys.include?(view)
          end

          # @api private
          # @since 2.1.0
          def corresponding_restful_view(view)
            RESTFUL_COUNTERPART_VIEWS.fetch(view, nil)
          end

          # @api private
          # @since 2.1.0
          def route_url(controller, action, url_path)
            action = ROUTE_RESTFUL_URL_SUFFIXES.fetch(action) { [action] }
            url_path ||= "#{PATH_SEPARATOR}#{(controller + action).join(PATH_SEPARATOR)}"

            CLI::URL.call(url_path)
          end

          # @api private
          # @since 2.1.0
          def route_http(action, http_method)
            result = (http_method ||= ROUTE_RESTFUL_HTTP_METHODS.fetch(action, ROUTE_DEFAULT_HTTP_METHOD)).downcase

            unless ROUTE_HTTP_METHODS.include?(result)
              raise UnknownHTTPMethodError.new(http_method)
            end

            result
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ParameterLists
