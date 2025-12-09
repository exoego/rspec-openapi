describe Hansi::Color do
  subject(:color) { Hansi::Color.new(255, 0, 0) }

  describe :hash do
    specify { color.hash.should be == Hansi["f00"].hash }
  end

  describe :eql? do
    specify { color.should be_eql Hansi["f00"] }
  end

  describe :to_s do
    specify { color.to_s.should be == "#ff0000" }
  end

  describe :to_css_rule do
    specify { color.to_css_rule.should be == "color: #ff0000;" }
  end

  describe :to_css do
    specify { color.to_css("name")         .should be == ".name {\n  color: #ff0000;\n}\n" }
    specify { color.to_css("name", &:to_s) .should be == "name {\n  color: #ff0000;\n}\n"  }
  end

  describe :to_web_name do
    specify { color.to_web_name.should be == :red }
  end

  describe :closest do
    specify { color.closest([color, Hansi[:orange]])        .should be == color }
    specify { color.closest([Hansi[:blue], Hansi[:orange]]) .should be == Hansi[:orange] }
  end

  describe :to_ansi do
    specify { color.to_ansi(mode: 0)                  .should be == ""                 }
    specify { color.to_ansi(mode: 8)                  .should be == "\e[31m"           }
    specify { color.to_ansi(mode: 16)                 .should be == "\e[91m"           }
    specify { color.to_ansi(mode: 88)                 .should be == "\e[38;5;9m"       }
    specify { color.to_ansi(mode: 256)                .should be == "\e[38;5;9m"       }
    specify { color.to_ansi(mode: Hansi::TRUE_COLOR)  .should be == "\e[38;2;255;0;0m" }

    specify "unknown mode" do
      expect { color.to_ansi(mode: 99) }.to raise_error(ArgumentError)
    end
  end
end
