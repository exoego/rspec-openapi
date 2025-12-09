# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The map_matcher plugin allows you to provide a string-keyed
    # hash during route matching, and match any of the keys in the hash
    # as the next segment in the request path, yielding the corresponding
    # value in the hash:
    #
    #   class App < Roda
    #     plugin :map_matcher
    #
    #     map = { "foo" => "bar", "baz" => "quux" }.freeze
    #
    #     route do
    #       r.get map: map do |v|
    #         v
    #         # GET /foo => bar
    #         # GET /baz => quux
    #       end
    #     end
    #   end
    module MapMatcher
      module RequestMethods
        private

        # Match only if the next segment in the path is one of the keys
        # in the hash, and yield the value of the hash.
        def match_map(hash)
          rp = @remaining_path
          if key = _match_class_String
            if value = hash[@captures[-1]]
              @captures[-1] = value
              true
            else
              @remaining_path = rp
              @captures.pop
              false
            end
          end
        end
      end
    end

    register_plugin(:map_matcher, MapMatcher)
  end
end
