#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  opt :default_false, "Boolean flag with false default", :default => false, :short => "f"
  opt :default_true, "Boolean flag with true default", :default => true, :short => "t"
end

puts opts
