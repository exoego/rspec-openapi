# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        # @since 2.0.0
        # @api private
        module Generate
          require_relative "generate/slice"
          require_relative "generate/action"
        end
      end
    end
  end
end
