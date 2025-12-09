describe Hansi::Theme do
  subject(:theme) { Hansi::Theme.new(foo: :bar, bar: :red) }

  describe :[] do
    specify { Hansi::Theme[:solarized][:yellow]            .should be == Hansi[181, 137, 0]                         }
    specify { Hansi::Theme[:default][:yellow]              .should be == Hansi[255, 255, 0]                         }
    specify { Hansi::Theme[Hansi::Theme[:solarized]]       .should be == Hansi::Theme[:solarized]                   }
    specify { Hansi::Theme[red: :blue]                     .should be == Hansi::Theme.new(red: :blue)               }
    specify { Hansi::Theme[[{red: :blue}, {green: :blue}]] .should be == Hansi::Theme.new(red: :blue, green: :blue) }
    specify { expect { Hansi::Theme[Object.new] }.to raise_error(ArgumentError) }
  end

  describe :[]= do
    specify do
      Hansi::Theme[:foo] = :solarized
      Hansi::Theme[:foo][:yellow].should be == Hansi[181, 137, 0]
    end
  end

  describe :merge do
    specify do
      new_theme = theme.merge(foo: :baz)
      expect(new_theme.rules).to include(foo: :baz)
    end
  end

  describe :hash do
    specify { Hansi::Theme[:default].hash.should be == Hansi::Theme[{}].hash }
  end

  describe :eql? do
    specify { Hansi::Theme[:default].should be_eql Hansi::Theme[{}] }
  end

  describe :to_h do
    specify { theme.to_h.should be == { foo: Hansi[:red], bar: Hansi[:red] }}
  end

  describe :to_css do
    specify { theme.to_css                       .should be == ".foo, .bar {\n  color: #ff0000;\n}\n" }
    specify { theme.to_css { |name| "##{name}" } .should be == "#foo, #bar {\n  color: #ff0000;\n}\n" }
  end
end
