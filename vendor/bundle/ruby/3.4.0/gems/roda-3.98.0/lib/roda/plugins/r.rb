# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The r plugin adds an +r+ instance method that will return the request.
    # This allows you to use common Roda idioms such as +r.halt+ and
    # +r.redirect+ even when +r+ isn't a local variable in scope. Example:
    # 
    #   plugin :r
    #
    #   def foo
    #     r.redirect "/bar"
    #   end
    #
    #   route do |r|
    #     r.get "foo" do
    #       foo
    #     end
    #     r.get "bar" do
    #       "bar"
    #     end
    #   end
    module R
      module InstanceMethods
        # The request object.
        def r
          @_request
        end
      end
    end

    register_plugin(:r, R)
  end
end
