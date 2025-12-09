# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The redirect_path plugin builds on top of the path plugin,
    # and allows the +r.redirect+ method to be passed a non-string
    # object that will be passed to +path+, and redirect to the
    # result of +path+.
    #
    # In the second argument, you can provide a suffix to the
    # generated path. However, in this case you cannot provide a
    # non-default redirect status in the same call).
    #
    # Example:
    #
    #   Foo = Struct.new(:id)
    #   foo = Foo.new(1)
    #
    #   plugin :redirect_path
    #   path Foo do |foo|
    #     "/foo/#{foo.id}"
    #   end
    #
    #   route do |r|
    #     r.get "example" do
    #       # redirects to /foo/1
    #       r.redirect(foo)
    #     end
    #
    #     r.get "suffix-example" do
    #       # redirects to /foo/1/status
    #       r.redirect(foo, "/status")
    #     end
    #   end
    module RedirectPath
      def self.load_dependencies(app)
        app.plugin :path
      end

      module RequestMethods
        def redirect(path=default_redirect_path, status=default_redirect_status)
          if String === path
            super
          else
            path = scope.path(path)
            if status.is_a?(String)
              super(path + status)
            else
              super
            end
          end
        end
      end
    end

    register_plugin(:redirect_path, RedirectPath)
  end
end
