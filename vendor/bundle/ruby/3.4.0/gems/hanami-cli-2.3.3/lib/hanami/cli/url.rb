# frozen_string_literal: true

require "uri"
require_relative "errors"

module Hanami
  module CLI
    # @since 2.0.0
    # @api private
    module URL
      DEFAULT_URL_PREFIX = "/"
      private_constant :DEFAULT_URL_PREFIX

      class << self
        # @since 2.0.0
        # @api private
        def call(url)
          result = url
          result = URI.parse(result).path

          unless valid?(result)
            raise InvalidURLError.new(url)
          end

          result
        rescue URI::InvalidURIError
          raise InvalidURLError.new(url)
        end
        alias_method :[], :call

        # @since 2.0.0
        # @api private
        def valid?(url)
          return false if url.nil?

          url.start_with?(DEFAULT_URL_PREFIX)
        end
      end
    end
  end
end
