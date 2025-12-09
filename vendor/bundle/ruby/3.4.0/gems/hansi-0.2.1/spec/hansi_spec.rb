describe Hansi do
  describe :mode_for do
    specify { Hansi.mode_for({})                             .should be == 0   }
    specify { Hansi.mode_for({'TERM' => 'footerm-256color'}) .should be == 256 }
  end

  describe :color_names do
    specify { Hansi.color_names.should include(:red)           }
    specify { Hansi.color_names.should include(:rebeccapurple) }
  end

  describe :render do
    subject(:renderer) { Hansi }

    context "string renderer" do
      it { should render("foo *bar*")                         .as("\e[0m\e[10mfoo *bar*\e[0m")               }
      it { should render("<foo>")                             .as("\e[0m\e[10m<foo>\e[0m")                   }
      it { should render("foo *bar*", "*" => :bold)           .as("\e[0m\e[10mfoo \e[0m\e[10m\e[1mbar\e[0m") }
      it { should render("foo \\*bar\\*", "*" => :bold)       .as("\e[0m\e[10mfoo *bar*\e[0m")               }
      it { should render("<bold>foo</bold>", tags: true)      .as("\e[0m\e[10m\e[1mfoo\e[0m")                }
      it { should render("foo", mode: 256, theme: :solarized) .as("\e[0m\e[38;5;66mfoo\e[0m")                }
      it { should render("*%s*", "*", "*" => :bold)           .as("\e[0m\e[10m\e[1m*\e[0m")                  }

      it { should_not render("<red>", tags: true)   }
      it { should_not render("*",     "*" => :bold) }
    end

    context 'sexp renderer' do
      it { should render([:red, "foo"])                         .as("\e[0m\e[91mfoo\e[0m")                       }
      it { should render([:red, [:blue, "b"], "c"], join: " ")  .as("\e[0m\e[91m\e[34mb\e[0m \e[0m\e[91mc\e[0m") }
      it { should render([:default, "foo"], theme: :solarized)  .as("\e[0m\e[90mfoo\e[0m")                       }
    end

    context 'color renderer' do
      it { should render(Hansi[:red])        .as("\e[91m")         }
      it { should render(Hansi[:red], "foo") .as("\e[91mfoo\e[0m") }
    end

    it { should_not render(Object.new) }
  end
end
