# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The partials plugin adds a +partial+ method, which renders 
    # templates without the layout.
    # 
    #   plugin :partials, views: 'path/2/views'
    # 
    # Template files are prefixed with an underscore:
    #
    #   partial('test')     # uses _test.erb
    #   partial('dir/test') # uses dir/_test.erb
    #
    # This is basically equivalent to:
    #
    #   render('_test')
    #   render('dir/_test')
    #
    # To render the same template once for each object in an enumerable,
    # you can use the +render_partials+ method:
    #
    #   each_partial([1,2,3], :foo) # uses _foo.erb
    #
    # This is basically equivalent to:
    #
    #   render_each([1,2,3], "_foo", local: :foo)
    #
    # This plugin depends on the render and render_each plugins.
    module Partials
      # Depend on the render plugin, passing received options to it.
      # Also depend on the render_each plugin.
      def self.load_dependencies(app, opts=OPTS)
        app.plugin :render, opts
        app.plugin :render_each
      end

      module InstanceMethods
        # For each object in the given enumerable, render the given
        # template (prefixing the template filename with an underscore).
        def each_partial(enum, template, opts=OPTS)
          unless opts.has_key?(:local)
            opts = Hash[opts]
            opts[:local] = render_each_default_local(template)
          end
          render_each(enum, partial_template_name(template.to_s), opts)
        end

        # Renders the given template without a layout, but
        # prefixes the template filename to use with an 
        # underscore.
        def partial(template, opts=OPTS)
          opts = parse_template_opts(template, opts)
          if opts[:template]
            opts[:template] = partial_template_name(opts[:template])
          end
          render_template(opts)
        end

        private

        # Prefix the template base filename with an underscore.
        def partial_template_name(template)
          segments = template.split('/')
          segments[-1] = "_#{segments[-1]}"
          segments.join('/')
        end
      end
    end

    register_plugin(:partials, Partials)
  end
end
