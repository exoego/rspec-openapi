# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The _symbol_regexp_matchers plugin is designed for internal use by other plugins,
    # for the historical behavior of a symbol matching an arbitrary segment by default
    # using a regexp.
    module SymbolRegexpMatchers
      module RequestMethods
        private

        # The regular expression to use for matching symbols.  By default, any non-empty
        # segment matches.
        def _match_symbol_regexp(s)
          "([^\\/]+)"
        end
      end
    end

    register_plugin(:_symbol_regexp_matchers, SymbolRegexpMatchers)
  end
end

