# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The static_routing plugin adds static_* routing class methods for handling
    # static routes (i.e. routes with static paths, no nesting or placeholders).  These
    # routes are processed before the normal routing tree and designed for
    # maximum performance.  This can be substantially faster than Roda's normal
    # tree based routing if you have large numbers of static routes, about 3-4x
    # for 100-10000 static routes.  Example:
    #
    #   plugin :static_routing
    #   
    #   static_route '/foo' do |r|
    #     @var = :foo
    #
    #     r.get do
    #       'Not actually reached'
    #     end
    #
    #     r.post{'static POST /#{@var}'}
    #   end
    #
    #   static_get '/foo' do |r|
    #     'static GET /foo'
    #   end
    #
    #   route do |r|
    #     'Not a static route'
    #   end
    #
    # A few things to note in the above example.  First, unlike most other
    # routing methods in Roda, these take the full path of the request, and only
    # match if r.path_info matches exactly.  This is why you need to include the
    # leading slash in the path argument.
    #
    # Second, the static_* routing methods only take a single string argument for
    # the path, they do not accept other options, and do not handle placeholders
    # in strings.  For any routes needing placeholders, you should use Roda's
    # routing tree.
    #
    # There are separate static_* methods for each type of request method, and these
    # request method specific routes are tried first.  There is also a static_route
    # method that will match regardless of the request method, if there is no
    # matching request methods specific route.  This is why the static_get
    # method call takes precedence over the static_route method call for /foo.
    # As shown above, you can use Roda's routing tree methods inside the
    # static_route block to have shared behavior for different request methods,
    # while still handling the request methods differently.
    module StaticRouting
      def self.load_dependencies(app)
        app.plugin :hash_paths
      end

      module ClassMethods
        # Add a static route for any request method.  These are
        # tried after the request method specific static routes (e.g.
        # static_get), but allow you to use Roda's routing tree
        # methods inside the route for handling shared behavior while
        # still allowing request method specific handling.
        def static_route(path, &block)
          hash_path(:static_routing, path, &block)
        end
        
        [:get, :post, :delete, :head, :options, :link, :patch, :put, :trace, :unlink].each do |meth|
          request_method = meth.to_s.upcase
          define_method("static_#{meth}") do |path, &block|
            hash_path(request_method, path, &block)
          end
        end
      end

      module InstanceMethods
        private

        # If there is a static routing method for the given path, call it
        # instead having the routing tree handle the request.
        def _roda_before_30__static_routing
          r = @_request
          r.hash_paths(r.request_method)
          r.hash_paths(:static_routing)
        end
      end
    end

    register_plugin(:static_routing, StaticRouting)
  end
end
