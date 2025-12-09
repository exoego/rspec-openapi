# frozen_string_literal: true

require "shellwords"

module Hanami
  module CLI
    class Naming
      def initialize(inflector:)
        @inflector = inflector
      end

      def action_name(name)
        inflector.underscore(escape(name)).gsub("/", ".")
      end

      private

      attr_reader :inflector

      def escape(name)
        Shellwords.shellescape(name)
      end
    end
  end
end
