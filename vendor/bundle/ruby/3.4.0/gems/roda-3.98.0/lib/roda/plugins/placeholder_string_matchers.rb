# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The placeholder_string_matcher plugin exists for backwards compatibility
    # with previous versions of Roda that allowed placeholders inside strings
    # if they were prefixed by colons:
    #
    #   plugin :placeholder_string_matchers
    #
    #   route do |r|
    #     r.is("foo/:bar") |v|
    #       # matches foo/baz, yielding "baz"
    #       # does not match foo, foo/, or foo/baz/
    #     end
    #   end
    #
    # It is not recommended to use this in new applications, and it is encouraged
    # to use separate string class or symbol matchers instead:
    #
    #   r.is "foo", String
    #   r.is "foo", :bar 
    #
    # If used with the symbol_matchers plugin, this plugin respects the regexps
    # for the registered symbols, but it does not perform the conversions, the
    # captures for the regexp are used directly as the captures for the match method.
    module PlaceholderStringMatchers
      def self.load_dependencies(app)
        app.plugin :_symbol_regexp_matchers
      end

      module RequestMethods
        private

        def _match_string(str)
          if str.index(":")
            consume(self.class.cached_matcher(str){Regexp.escape(str).gsub(/:(\w+)/){|m| _match_symbol_regexp($1)}})
          else
            super
          end
        end
      end
    end

    register_plugin(:placeholder_string_matchers, PlaceholderStringMatchers)
  end
end
