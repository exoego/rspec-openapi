# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The match_hook plugin adds hooks that are called upon a successful match
    # by any of the matchers.  The hooks do not take any arguments.  If you would
    # like hooks that pass the arguments/matchers and values yielded to the route block,
    # use the match_hook_args plugin. This uses the match_hook_args plugin internally,
    # but doesn't pass the matchers and values yielded.
    #
    #   plugin :match_hook
    #
    #   match_hook do
    #     logger.debug("#{request.matched_path} matched. #{request.remaining_path} remaining.")
    #   end
    module MatchHook
      def self.load_dependencies(app)
        app.plugin :match_hook_args
      end

      module ClassMethods
        # Add a match hook.
        def match_hook(&block)
          meth = define_roda_method("match_hook", 0, &block)
          add_match_hook{|_,_| send(meth)}
          nil
        end
      end
    end

    register_plugin :match_hook, MatchHook
  end
end
