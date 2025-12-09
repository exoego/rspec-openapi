#!/usr/bin/env ruby
require_relative '../lib/optimist'

Optimist::options do
  synopsis "Overall synopsis of this program"
  version "cool-script v0.3 (code-name: apple-cake)"
  opt :juice, "use juice"
  opt :milk, "use milk"
  opt :litres, "quantity of liquid", :default => 2.0
  opt :brand, "brand name of the liquid", :type => :string
end
