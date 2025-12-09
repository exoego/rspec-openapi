#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  opt :cone, "Ice cream cone"
  opt :zippy, "It zips"
  opt :zapzy, "It zapz"
  opt :big_bug, "Madagascar cockroach"
end
p opts

# $ ./didyoumean.rb --one
# Error: unknown argument '--one'.  Did you mean: [--cone] ?.
# Try --help for help.

# $ ./didyoumean.rb --zappy
# Error: unknown argument '--zappy'.  Did you mean: [--zapzy, --zippy] ?.
# Try --help for help.

# $ ./didyoumean.rb --big_bug
# Error: unknown argument '--big_bug'.  Did you mean: [--big-bug] ?.
# Try --help for help.

# $ ./didyoumean.rb --bigbug
# Error: unknown argument '--bigbug'.  Did you mean: [--big-bug] ?.
# Try --help for help.
