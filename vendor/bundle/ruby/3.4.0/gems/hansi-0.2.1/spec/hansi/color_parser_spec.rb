describe Hansi::ColorParser do
  subject(:parser) { Hansi::ColorParser }
  it { should parse("#f00")             .as(red: 255)                        }
  it { should parse("00ff00")           .as(green: 255)                      }
  it { should parse("#f")               .as(red: 255, green: 255, blue: 255) }
  it { should parse("#f0")              .as(red: 240, green: 240, blue: 240) }
  it { should parse(red: 1.0)           .as(red: 255)                        }
  it { should parse(red: 300)           .as(red: 255)                        }
  it { should parse(red: -10)           .as(red: 0)                          }
  it { should parse(:rebeccapurple)     .as(red: 102, green: 51,  blue: 153) }
  it { should parse("\e[31m")           .as(red: 194, green: 54,  blue:  33) }
  it { should parse("\e[38;5;208m")     .as(red: 255, green: 135, blue:   0) }
  it { should parse("\e[38;2;255;0;0m") .as(red: 255)                        }

  it { should_not parse("#ffff")    }
  it { should_not parse(Object.new) }
end