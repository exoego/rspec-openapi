# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The assume_ssl plugin makes the request ssl? method always return
    # true. This is useful when using an SSL-terminating reverse proxy
    # that doesn't set the X-Forwarded-Proto or similar header to notify
    # Rack that it is forwarding an SSL request.
    #
    # The sessions and sinatra_helpers plugins that ship with Roda both
    # use the ssl? method internally and can be affected by use of the
    # plugin.  It's recommended that you use this plugin if you are
    # using either plugin and an SSL-terminating proxy as described above.
    #
    #   plugin :assume_ssl
    module AssumeSSL
      module RequestMethods
        # Assume all requests are protected by SSL.
        def ssl?
          true
        end
      end
    end

    register_plugin(:assume_ssl, AssumeSSL)
  end
end
