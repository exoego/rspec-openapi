# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The hooks plugin adds before and after hooks to the request cycle.
    #
    #   plugin :hooks
    #
    #   before do
    #     request.redirect('/login') unless logged_in?
    #     @time = Time.now
    #   end
    #
    #   after do |res|
    #     logger.notice("Took #{Time.now - @time} seconds")
    #   end
    #
    # Note that in general, before hooks are not needed, since you can just
    # run code at the top of the route block:
    #
    #   route do |r|
    #     r.redirect('/login') unless logged_in?
    #     # ...
    #   end
    #
    # However, this code makes it easier to write after hooks, as well as
    # handle cases where before hooks are added after the route block.
    #
    # Note that the after hook is called with the rack response array
    # of status, headers, and body.  If it wants to change the response,
    # it must mutate this argument, calling <tt>response.status=</tt> inside
    # an after block will not affect the returned status. Note that after
    # hooks can be called with nil if an exception is raised during routing.
    module Hooks
      def self.configure(app)
        app.opts[:after_hooks] ||= []
        app.opts[:before_hooks] ||= []
      end

      module ClassMethods
        # Freeze the array of hook methods when freezing the app.
        def freeze
          opts[:after_hooks].freeze
          opts[:before_hooks].freeze

          super
        end

        # Add an after hook.
        def after(&block)
          opts[:after_hooks] << define_roda_method("after_hook", 1, &block)
          if opts[:after_hooks].length == 1
            class_eval("alias _roda_after_80__hooks #{opts[:after_hooks].first}", __FILE__, __LINE__)
          else
            class_eval("def _roda_after_80__hooks(res) #{opts[:after_hooks].map{|m| "#{m}(res)"}.join(';')} end", __FILE__, __LINE__)
          end
          private :_roda_after_80__hooks
          def_roda_after
          nil
        end

        # Add a before hook.
        def before(&block)
          opts[:before_hooks].unshift(define_roda_method("before_hook", 0, &block))
          if opts[:before_hooks].length == 1
            class_eval("alias _roda_before_10__hooks #{opts[:before_hooks].first}", __FILE__, __LINE__)
          else
            class_eval("def _roda_before_10__hooks; #{opts[:before_hooks].join(';')} end", __FILE__, __LINE__)
          end
          private :_roda_before_10__hooks
          def_roda_before
          nil
        end
      end

      module InstanceMethods
        private

        # Default method if no after hooks are defined.
        def _roda_after_80__hooks(res)
        end

        # Default method if no before hooks are defined.
        def _roda_before_10__hooks
        end
      end
    end

    register_plugin(:hooks, Hooks)
  end
end
