# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The head plugin attempts to automatically handle HEAD requests,
    # by treating them as GET requests and returning an empty body
    # without modifying the response status or response headers.
    #
    # So for the following routes,
    #
    #   route do |r|
    #     r.root do
    #       'root'
    #     end
    #
    #     r.get 'a' do
    #       'a'
    #     end
    #
    #     r.is 'b', method: [:get, :post] do
    #       'b'
    #     end
    #   end
    #
    # HEAD requests for +/+, +/a+, and +/b+ will all return 200 status
    # with an empty body.
    #
    # This plugin also works with the not_allowed plugin if it is loaded
    # after the not_allowed plugin.  In that case, if GET is one of Allow
    # header options, then HEAD will be as well.
    #
    # NOTE: if you have a public facing website it is recommended that
    # you enable this plugin, or manually handle HEAD anywhere you would
    # handle GET. Search engines and other bots may send a
    # HEAD request prior to crawling a page with a GET request. Without
    # this plugin those HEAD requests will return a 404 status, which
    # may prevent search engines from crawling your website.
    module Head
      # used to ensure proper resource release on HEAD requests
      # we do not respond to a to_path method, here.
      class CloseLater
        def initialize(body)
          @body = body
        end

        # yield nothing
        def each(&_)
        end

        # this should be called by the Rack server
        def close
          @body.close
        end
      end

      module InstanceMethods
        private

        # Always use an empty response body for head requests, with a
        # content length of 0.
        def _roda_after_30__head(res)
          if res && @_request.head?
            body = res[2]
            if body.respond_to?(:close)
              res[2] = CloseLater.new(body)
            else
              res[2] = EMPTY_ARRAY
            end
          end
        end
      end

      module RequestMethods
        # Consider HEAD requests as GET requests.
        def is_get?
          super || head?
        end

        private

        # If the current request is a HEAD request, match if one of
        # the given methods is a GET request.
        def match_method(method)
          super || (!method.is_a?(Array) && head? && method.to_s.upcase == 'GET')
        end

        # Work with the not_allowed plugin so that if GET is one
        # of the Allow header options, then HEAD is as well.
        def method_not_allowed(verbs)
          verbs = verbs.sub('GET', 'HEAD, GET')
          super
        end
      end
    end

    register_plugin(:head, Head)
  end
end
