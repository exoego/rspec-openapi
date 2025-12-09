# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    module DelayBuild
      module ClassMethods
        # No-op for backwards compatibility
        def build!
        end
      end
    end

    # RODA4: Remove plugin
    # Only available for backwards compatibility, no longer needed
    register_plugin(:delay_build, DelayBuild)
  end
end
