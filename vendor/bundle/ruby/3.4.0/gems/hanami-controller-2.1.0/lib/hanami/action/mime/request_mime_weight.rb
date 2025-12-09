# frozen_string_literal: true

module Hanami
  class Action
    module Mime
      # @since 1.0.1
      # @api private
      class RequestMimeWeight
        # @since 2.0.0
        # @api private
        MIME_SEPARATOR = "/"
        private_constant :MIME_SEPARATOR

        # @since 2.0.0
        # @api private
        MIME_WILDCARD = "*"
        private_constant :MIME_WILDCARD

        include Comparable

        # @since 1.0.1
        # @api private
        attr_reader :quality

        # @since 1.0.1
        # @api private
        attr_reader :index

        # @since 1.0.1
        # @api private
        attr_reader :mime

        # @since 1.0.1
        # @api private
        attr_reader :format

        # @since 1.0.1
        # @api private
        attr_reader :priority

        # @since 1.0.1
        # @api private
        def initialize(mime, quality, index, format = mime)
          @quality, @index, @format = quality, index, format
          calculate_priority(mime)
        end

        # @since 1.0.1
        # @api private
        def <=>(other)
          return priority <=> other.priority unless priority == other.priority

          other.index <=> index
        end

        private

        # @since 1.0.1
        # @api private
        def calculate_priority(mime)
          @priority ||= (mime.split(MIME_SEPARATOR, 2).count(MIME_WILDCARD) * -10) + quality
        end
      end
    end
  end
end
