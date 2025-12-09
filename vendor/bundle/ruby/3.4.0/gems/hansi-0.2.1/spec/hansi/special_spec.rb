describe Hansi::Special do
  describe :to_css_rule do
    example { Hansi[:bold]    .to_css_rule.should be == 'font-weight: bold;' }
    example { Hansi[:fraktur] .to_css_rule.should be == '/* cannot convert <Hansi::Special:"\e[20m"> to css */' }
  end
end
