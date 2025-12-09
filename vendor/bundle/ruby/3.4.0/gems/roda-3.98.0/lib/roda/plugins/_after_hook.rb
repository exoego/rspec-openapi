# frozen-string-literal: true

require_relative 'error_handler'

#
class Roda
  module RodaPlugins
    # RODA4: Remove
    register_plugin(:_after_hook, ErrorHandler)
  end
end
