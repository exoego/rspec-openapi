# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The plain_hash_response_headers plugin will change Roda to
    # use a plain hash for response headers.  This is Roda's
    # default behavior on Rack 2, but on Rack 3+, Roda defaults
    # to using Rack::Headers for response headers for backwards
    # compatibility (Rack::Headers automatically lower cases header
    # keys).
    #
    # On Rack 3+, you should use this plugin for better performance
    # if you are sure all headers in your application and middleware
    # are already lower case (lower case response header keys are
    # required by the Rack 3 spec).
    module PlainHashResponseHeaders
      if defined?(Rack::Headers) && Rack::Headers.is_a?(Class)
        module ResponseMethods
          private

          # Use plain hash for headers
          def _initialize_headers
            {}
          end
        end
      end
    end

    register_plugin(:plain_hash_response_headers, PlainHashResponseHeaders)
  end
end
