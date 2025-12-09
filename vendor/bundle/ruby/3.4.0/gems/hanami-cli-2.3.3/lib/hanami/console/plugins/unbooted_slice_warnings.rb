# frozen_string_literal: true

module Hanami
  module Console
    module Plugins
      # Console plugin that prints a one-time warning when an unbooted slice is asked for its
      # `.keys`.
      #
      # @api private
      module UnbootedSliceWarnings
        module SliceExtension
        end

        def self.activate
          warning_shown_for_slice = {}

          # Define the wrapper method with access to the context via closure
          SliceExtension.define_method(:keys) do
            if !booted? && !warning_shown_for_slice[self]
              message = <<~TEXT
                Warning: #{self} is not booted. Run `#{self}.boot` to load all components, or launch the console with `--boot`.
              TEXT
              warn message

              warning_shown_for_slice[self] = true
            end

            super()
          end

          Hanami::Slice::ClassMethods.prepend(SliceExtension)
        end

        def self.deactivate
          SliceExtension.remove_method :keys
        end
      end
    end
  end
end
