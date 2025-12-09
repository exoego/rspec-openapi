# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The precompile_templates plugin adds support for precompiling template code.
    # This can result in a large memory savings for applications that have large
    # templates or a large number of small templates if the application uses a
    # forking webserver.  By default, template compilation is lazy, so all the
    # child processes in a forking webserver will have their own copy of the
    # compiled template.  By using the precompile_templates plugin, you can
    # precompile the templates in the parent process before forking, and then
    # all of the child processes can use the same precompiled templates, which
    # saves memory.
    #
    # Another advantage of the precompile_templates plugin is that after
    # template precompilation, access to the template file in the file system is
    # no longer needed, so this can be used with security features that do not
    # allow access to the template files at runtime.
    #
    # After loading the plugin, you should call precompile_views with an array
    # of views to compile, using the same argument you are passing to view or
    # render:
    #
    #   plugin :precompile_templates
    #   precompile_views %w'view1 view2'
    #   
    # If the view requires local variables, you should call precompile_views with a second
    # argument for the local variables:
    #
    #   plugin :precompile_templates
    #   precompile_views :view3, [:local_var1, :local_var2]
    #
    # After all templates are precompiled, you can optionally use freeze_template_caches!,
    # which will freeze the template caches so that any template compilation at runtime
    # will result in an error.  This also speeds up template cache access, since the
    # template caches no longer need a mutex.
    #
    #   freeze_template_caches!
    #
    # Note that you should use Tilt 2.0.1+ if you are using this plugin, so
    # that locals are handled in the same order.
    module PrecompileTemplates
      # Load the render plugin as precompile_templates depends on it.
      def self.load_dependencies(app, opts=OPTS)
        app.plugin :render
      end

      module ClassMethods
        # Freeze the template caches.  Should be called after precompiling all templates during
        # application startup, if you don't want to allow templates to be cached at runtime.
        # In addition to ensuring that no templates are compiled at runtime, this also speeds
        # up rendering by freezing the template caches, so that a mutex is not needed to access
        # them.
        def freeze_template_caches!
          _freeze_layout_method

          opts[:render] = render_opts.merge(
            :cache=>render_opts[:cache].freeze,
            :template_method_cache=>render_opts[:template_method_cache].freeze,
          ).freeze
          self::RodaCompiledTemplates.freeze

          nil
        end

        # Precompile the templates using the given options.  Note that this doesn't
        # handle optimized template methods supported in newer versions of Roda, but
        # there are still cases where makes sense to use it.
        #
        # You can call +precompile_templates+ with the pattern of templates you would
        # like to precompile:
        #
        #   precompile_templates "views/**/*.erb"
        #
        # That will precompile all erb template files in the views directory or
        # any subdirectory.
        #
        # If the templates use local variables, you need to specify which local
        # variables to precompile, which should be an array of symbols:
        #
        #   precompile_templates 'views/users/_*.erb', locals: [:user]
        #
        # You can specify other render options when calling +precompile_templates+,
        # including +:cache_key+, +:template_class+, and +:template_opts+.  If you
        # are passing any of those options to render/view for the template, you
        # should pass the same options when precompiling the template.
        #
        # To compile inline templates, just pass a single hash containing an :inline
        # to +precompile_templates+:
        #
        #   precompile_templates inline: some_template_string
        def precompile_templates(pattern, opts=OPTS)
          if pattern.is_a?(Hash)
            opts = pattern.merge(opts)
          end

          if locals = opts[:locals]
            locals.sort!
          else
            locals = EMPTY_ARRAY
          end

          compile_opts = if pattern.is_a?(Hash)
            [opts]
          else
            Dir[pattern].map{|file| opts.merge(:path=>File.expand_path(file, nil))}
          end

          instance = allocate
          compile_opts.each do |compile_opt|
            template = instance.send(:retrieve_template, compile_opt)
            begin
              Render.tilt_template_compiled_method(template, locals, self)
            rescue NotImplementedError
              # When freezing template caches, you may want to precompile a template for a
              # template type that doesn't support template precompilation, just to populate
              # the cache.  Tilt rescues NotImplementedError in this case, which we can ignore.
              nil
            end
          end

          nil
        end

        # Precompile the given views with the given locals, handling optimized template methods.
        def precompile_views(views, locals=EMPTY_ARRAY)
          instance = allocate
          views = Array(views)

          if locals.empty?
            opts = OPTS
          else
            locals_hash = {}
            locals.each{|k| locals_hash[k] = nil}
            opts = {:locals=>locals_hash}
          end

          views.each do |view|
            instance.send(:retrieve_template, instance.send(:render_template_opts, view, opts))
          end

          if locals_hash
            views.each do |view|
              instance.send(:_optimized_render_method_for_locals, view, locals_hash)
            end
          end

          nil
        end
      end
    end

    register_plugin(:precompile_templates, PrecompileTemplates)
  end
end
