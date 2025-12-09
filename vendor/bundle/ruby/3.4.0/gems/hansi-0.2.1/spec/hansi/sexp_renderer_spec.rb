describe Hansi::SexpRenderer do
  before { Hansi.mode = 16 }
  subject(:renderer) { Hansi::SexpRenderer }
  it { should render([:red, "foo"])                         .as("\e[0m\e[91mfoo\e[0m")                       }
  it { should render([:red, [:blue, "b"], "c"], join: " ")  .as("\e[0m\e[91m\e[34mb\e[0m \e[0m\e[91mc\e[0m") }
  it { should render([:default, "foo"], theme: :solarized)  .as("\e[0m\e[90mfoo\e[0m")                       }
end