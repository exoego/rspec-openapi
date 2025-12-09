# frozen_string_literal: true

module Dry
  module System
    class Loader
      # Component loader for autoloading-enabled applications
      #
      # This behaves like the default loader, except instead of requiring the given path,
      # it loads the respective constant, allowing the autoloader to load the
      # corresponding file per its own configuration.
      #
      # @see Loader
      # @api public
      class Autoloading < Loader
        class << self
          def require!(component)
            constant(component)
            self
          end
        end
      end
    end
  end
end
