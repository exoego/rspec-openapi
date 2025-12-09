# frozen_string_literal: true

require "hanami/utils/blank"

module Hanami
  class Action
    module Cache
      # ETag value object
      #
      # @since 0.3.0
      # @api private
      class ETag
        # @since 0.3.0
        # @api private
        def initialize(env, value)
          @env, @value = env, value
        end

        # @since 0.3.0
        # @api private
        def fresh?
          none_match && @value == none_match
        end

        # @since 0.3.0
        # @api private
        def header
          {Action::ETAG => @value} if @value
        end

        private

        # @since 0.3.0
        # @api private
        def none_match
          @env[Action::IF_NONE_MATCH]
        end
      end

      # LastModified value object
      #
      # @since 0.3.0
      # @api private
      class LastModified
        # @since 0.3.0
        # @api private
        def initialize(env, value)
          @env, @value = env, value
        end

        # @since 0.3.0
        # @api private
        def fresh?
          return false if Hanami::Utils::Blank.blank?(modified_since)
          return false if Hanami::Utils::Blank.blank?(@value)

          Time.httpdate(modified_since).to_i >= @value.to_time.to_i
        end

        # @since 0.3.0
        # @api private
        def header
          {Action::LAST_MODIFIED => @value.httpdate} if @value.respond_to?(:httpdate)
        end

        private

        # @since 0.3.0
        # @api private
        def modified_since
          @env[Action::IF_MODIFIED_SINCE]
        end
      end

      # Class responsible to determine if a given request is fresh
      # based on IF_NONE_MATCH and IF_MODIFIED_SINCE headers
      #
      # @since 0.3.0
      # @api private
      class ConditionalGet
        # @since 0.3.0
        # @api private
        def initialize(env, options)
          @validations = [ETag.new(env, options[:etag]), LastModified.new(env, options[:last_modified])]
        end

        # @since 0.3.0
        # @api private
        def fresh?
          yield if @validations.any?(&:fresh?)
        end

        # @since 0.3.0
        # @api private
        def headers
          @validations.map(&:header).compact.reduce({}, :merge)
        end
      end
    end
  end
end
