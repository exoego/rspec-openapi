# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # Internal before hook module, not for external use.
    # Allows for plugins to configure the order in which
    # before processing is done by using _roda_before_*
    # private instance methods that are called in sorted order.
    # Loaded automatically by the base library if any _roda_before_*
    # methods are defined.
    module BeforeHook # :nodoc:
      module InstanceMethods
        # Run internal before hooks - Old Dispatch API.
        def call(&block)
          # RODA4: Remove
          super do
            _roda_before
            instance_exec(@_request, &block) # call Fallback
          end
        end

        # Run internal before hooks before running the main
        # roda route.
        def _roda_run_main_route(r)
          _roda_before
          super
        end

        private

        # Default empty implementation of _roda_before, usually
        # overridden by Roda.def_roda_before.
        def _roda_before
        end
      end
    end

    register_plugin(:_before_hook, BeforeHook)
  end
end
