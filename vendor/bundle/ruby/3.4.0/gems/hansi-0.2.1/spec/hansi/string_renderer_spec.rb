describe Hansi::StringRenderer do
  before { Hansi.mode = 16 }
  subject(:renderer) { Hansi::StringRenderer }

  it { should render("foo *bar*")                         .as("\e[0m\e[10mfoo *bar*\e[0m")               }
  it { should render("<foo>")                             .as("\e[0m\e[10m<foo>\e[0m")                   }
  it { should render("foo *bar*", "*" => :bold)           .as("\e[0m\e[10mfoo \e[0m\e[10m\e[1mbar\e[0m") }
  it { should render("foo \\*bar\\*", "*" => :bold)       .as("\e[0m\e[10mfoo *bar*\e[0m")               }
  it { should render("<bold>foo</bold>", tags: true)      .as("\e[0m\e[10m\e[1mfoo\e[0m")                }
  it { should render("foo", mode: 256, theme: :solarized) .as("\e[0m\e[38;5;66mfoo\e[0m")                }
  it { should render("*%s*", "*", "*" => :bold)           .as("\e[0m\e[10m\e[1m*\e[0m")                  }

  it { should_not render("<red>", tags: true)   }
  it { should_not render("*",     "*" => :bold) }

  describe :escape do
    context "special character" do
      subject(:renderer) { Hansi::StringRenderer.new({"*" => :bold}) }
      it { should escape("foo *bar*").as("foo \\*bar\\*") }
    end

    context "nothing special" do
      subject(:renderer) { Hansi::StringRenderer.new }
      it { should escape("<foo> *bar*").as("<foo> *bar*") }
    end

    context "tags" do
      subject(:renderer) { Hansi::StringRenderer.new(tags: true) }
      it { should escape("<foo> bar").as("\\<foo\\> bar") }
    end
  end
end
