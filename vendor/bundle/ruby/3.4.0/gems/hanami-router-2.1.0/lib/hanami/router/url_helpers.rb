# frozen_string_literal: true

require "hanami/router/errors"
require "mustermann/error"
require_relative "prefix"

module Hanami
  class Router
    # @since 2.0.0
    # @api private
    class UrlHelpers
      # @since 2.0.0
      # @api private
      def initialize(base_url)
        @base_url = URI(base_url)
        @named = {}
        prefix = @base_url.path
        prefix = DEFAULT_PREFIX if prefix.empty?
        @prefix = Prefix.new(prefix)
      end

      # @since 2.0.0
      # @api private
      def add(name, segment)
        @named[name] = segment
      end

      # @since 2.0.0
      # @api private
      def path(name, variables = {})
        @named.fetch(name.to_sym) do
          raise MissingRouteError.new(name)
        end.expand(:append, variables)
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionError.new(name, exception.message)
      end

      # @since 2.0.0
      # @api private
      def url(name, variables = {})
        @base_url + @prefix.join(path(name, variables)).to_s
      end
    end
  end
end
