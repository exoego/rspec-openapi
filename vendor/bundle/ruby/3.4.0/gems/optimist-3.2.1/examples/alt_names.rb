#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  # 'short:' can now take more than one short-option character
  #   you can specify 'short:' as a string/symbol or an array of strings/symbols
  # 'alt:' adds additional long-opt choices (over the original name or the long: name)
  #   you can specify 'alt:' as a string/symbol or an array of strings/symbols.
  #
  opt :concat, 'concatenate flag', short: ['-C', 'A'], alt: ['cat', '--append']
  opt :array_len, 'set Array length', long: 'size', alt: 'length', type: Integer
end

p opts

# $ ./alt_names.rb -h
# Options:
#   -C, -A, --concat, --cat, --append    concatenate flag
#   -s, --size, --length=<i>             set Array length
#   -h, --help                           Show this message
