#!/usr/bin/env ruby
require_relative '../lib/optimist'

opts = Optimist::options do
  opt :monkey, "Use monkey mode"                    # flag --monkey, default false
  opt :name, "Monkey name", :type => :string        # string --name <s>, default nil
  opt :num_limbs, "Number of limbs", :default => 4  # integer --num-limbs <i>, default to 4
end
p opts
