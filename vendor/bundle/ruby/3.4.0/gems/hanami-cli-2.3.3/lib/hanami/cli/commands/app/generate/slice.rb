# frozen_string_literal: true

require "dry/inflector"
require "dry/files"
require "shellwords"
require_relative "../../../errors"

module Hanami
  module CLI
    module Commands
      module App
        module Generate
          # @since 2.0.0
          # @api private
          class Slice < App::Command
            argument :name, required: true, desc: "The slice name"
            option :url, required: false, type: :string, desc: "The slice URL prefix"

            # @since 2.2.0
            # @api private
            SKIP_DB_DEFAULT = false
            private_constant :SKIP_DB_DEFAULT

            # @since 2.2.0
            # @api private
            DEFAULT_SKIP_ROUTE = false
            private_constant :DEFAULT_SKIP_ROUTE

            # @since 2.2.0
            # @api private
            option :skip_db,
                   type: :flag,
                   required: false,
                   default: SKIP_DB_DEFAULT,
                   desc: "Skip database"
            # @since 2.2.0
            # @api private
            option :skip_route,
                   type: :flag,
                   required: false,
                   default: DEFAULT_SKIP_ROUTE,
                   desc: "Skip route generation"

            example [
              "admin          # Admin slice (/admin URL prefix)",
              "users --url=/u # Users slice (/u URL prefix)",
            ]

            # @since 2.0.0
            # @api private
            def initialize(
              fs:,
              generator: Generators::App::Slice.new(fs: fs, inflector: inflector),
              **opts
            )
              super(fs: fs, **opts)
              @generator = generator
            end

            # @since 2.0.0
            # @api private
            def call(
              name:,
              url: nil,
              skip_db: SKIP_DB_DEFAULT,
              skip_route: DEFAULT_SKIP_ROUTE
            )
              require "hanami/setup"

              app = inflector.underscore(Hanami.app.namespace)
              name = inflector.underscore(Shellwords.shellescape(name))
              url = sanitize_url_prefix(name, url)

              generator.call(app, name, url, skip_db: skip_db, skip_route: skip_route)
            end

            private

            DEFAULT_URL_PREFIX = "/"
            private_constant :DEFAULT_URL_PREFIX

            attr_reader :generator

            def sanitize_url_prefix(name, url)
              result = url
              result = inflector.underscore(Shellwords.shellescape(result)) unless result.nil?

              result ||= DEFAULT_URL_PREFIX + name
              CLI::URL.call(result)
            rescue InvalidURLError
              raise InvalidURLPrefixError.new(url)
            end

            def valid_url?(url)
              return false if url.nil?

              url.start_with?(DEFAULT_URL_PREFIX)
            end
          end
        end
      end
    end
  end
end
