#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options(ARGV, exact_match: false) do
  opt :apple, "An apple"
  opt :apple_sauce, "Cooked apple puree"
  opt :atom, "Smallest unit of ordinary matter"
  opt :anvil, "Heavy metal"
  opt :anteater, "Eats ants"
end
p opts

# $ ./partialmatch.rb  --anv 1
# {:apple=>false, :apple_sauce=>false, :atom=>false, :anvil=>true, :anteater=>false, :help=>false, :anvil_given=>true}
#
# $ ./partialmatch.rb  --an 1
# Error: ambiguous option '--an' matched keys (anvil,anteater).
# Try --help for help.
