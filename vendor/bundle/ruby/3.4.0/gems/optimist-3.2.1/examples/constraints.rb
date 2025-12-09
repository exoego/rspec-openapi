#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  opt :dog, "user is dog"
  opt :cat, "user is cat"
  opt :rat, "user is rat"
  conflicts :dog, :cat, :rat

  opt :wash, "pet wash"
  opt :dry, "pet dry"
  depends :wash, :dry

  opt :credit, "pay creditcard"
  opt :cash, "pay cash"
  opt :cheque, "pay cheque"
  either :credit, :cash, :cheque
end
p opts

# $ ./constraints.rb --dog --cat
# Error: only one of --dog, --cat, --rat can be given.

# $ ./constraints.rb --dog --wash
# Error: --wash, --dry have a dependency and must be given together.

# $ ./constraints.rb --cash --cheque --rat --wash --dry
# Error: one and only one of --credit, --cash, --cheque is required.
