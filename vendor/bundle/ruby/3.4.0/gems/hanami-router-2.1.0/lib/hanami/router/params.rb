# frozen_string_literal: true

module Hanami
  class Router
    # Params utilities
    #
    # @since 2.0.0
    # @api private
    class Params
      # Deep symbolize Hash params
      #
      # @param params [Hash] the params to symbolize
      #
      # @return [Hash] the symbolized params
      #
      # @api private
      # @since 2.0.0
      def self.deep_symbolize(params)
        params.each_with_object({}) do |(key, value), output|
          output[key.to_sym] =
            case value
            when ::Hash
              deep_symbolize(value)
            when Array
              value.map do |item|
                item.is_a?(::Hash) ? deep_symbolize(item) : item
              end
            else
              value
            end
        end
      end
    end
  end
end
