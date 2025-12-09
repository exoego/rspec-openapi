# frozen_string_literal: true

require "delegate"

module Hanami
  module Console
    module Plugins
      # @api private
      # @since 2.0.0
      class SliceReaders < Module
        # @since 2.0.0
        # @api private
        def initialize(app)
          super()

          app.slices.each do |slice|
            define_method(slice.slice_name.to_sym) do
              slice
            end
          end
        end
      end
    end
  end
end
