# frozen_string_literal: true

require_relative "../constants"

module Hanami
  module CLI
    module Generators
      module App
        # @api private
        class RubyClassFile < RubyFile
          def initialize(parent_class_name: nil, **args)
            super

            @parent_class_name = parent_class_name
          end

          private

          attr_reader :parent_class_name

          def class_name
            constant_name
          end

          def modules
            namespace_modules
          end
        end
      end
    end
  end
end
