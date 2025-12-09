#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  opt :french, "starts with french", type: String,
      permitted: %w(fries toast),
      permitted_response: "option %{arg} must be something that starts " +
      "with french, e.g. %{permitted} but you gave '%{given}'"
  opt :dog, "starts with dog", permitted: %r/(house|bone|tail)/, type: String
  opt :zipcode, "zipcode", permitted: %r/^[0-9]{5}$/, default: '39759',
      permitted_response: "option %{arg} must be a zipcode, a five-digit number from 00000..99999"
  opt :adult, "adult age", permitted: (18...99), type: Integer
  opt :minor, "minor age", permitted: (0..18), type: Integer
  opt :letter, "a letter", permitted: ('a'...'z'), type: String
end

p opts

# $ ./permitted.rb -z 384949
# Error: option -z must be a zipcode, a five-digit number from 00000..99999.
# Try --help for help.
#
# $ ./permitted.rb --minor 19
# Error: option '--minor' only accepts value in range of: 0..18.
# Try --help for help.
#
# $ ./permitted.rb -f frog
# Error: option -f must be something that starts with french, e.g. ["fries", "toast"] but you gave 'frog'.
# Try --help for help.
