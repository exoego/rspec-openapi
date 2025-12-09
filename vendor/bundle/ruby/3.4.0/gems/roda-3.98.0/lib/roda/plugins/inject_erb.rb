# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The inject_erb plugin allows you to inject content directly
    # into the template output:
    #
    #   <% inject_erb("Some HTML Here") %>
    #
    # This will inject <tt>Some HTML Here</tt> into the template output,
    # even though the tag being used is <tt><%</tt> and not <tt><%=</tt>.
    #
    # This method can be used inside methods, such as to wrap calls to
    # methods that accept template blocks, to inject code before and after
    # the template blocks.
    module InjectERB
      def self.load_dependencies(app)
        app.plugin :render
      end

      module InstanceMethods
        # Inject into the template output for the template currently being
        # rendered.
        def inject_erb(value)
          instance_variable_get(render_opts[:template_opts][:outvar]) << value.to_s
        end
      end
    end

    register_plugin(:inject_erb, InjectERB)
  end
end
