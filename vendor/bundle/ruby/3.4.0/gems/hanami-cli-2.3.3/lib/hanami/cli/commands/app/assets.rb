# frozen_string_literal: true

module Hanami
  module CLI
    module Commands
      module App
        # @since 2.1.0
        # @api private
        module Assets
          require_relative "assets/compile"
          require_relative "assets/watch"
        end
      end
    end
  end
end
