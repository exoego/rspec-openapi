#!/usr/bin/env ruby
require_relative '../lib/optimist'

Optimist::options do
  version "cool-script v0.3.2 (code-name: apple-cake)"
  banner self.version  ## print out the version in the banner
  banner "drinks"
  opt :juice, "use juice"
  opt :milk, "use milk"
  banner "drink control"    ## can be used for categories
  opt :litres, "quantity of liquid", :default => 2.0
  opt :brand, "brand name of the liquid", :type => :string
  banner "other controls"
end
