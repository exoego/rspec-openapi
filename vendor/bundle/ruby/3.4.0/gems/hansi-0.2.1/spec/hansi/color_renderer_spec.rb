describe Hansi::ColorRenderer do
  before { Hansi.mode = 16 }
  subject(:renderer) { Hansi::ColorRenderer }
  it { should render(Hansi[:red]).as("\e[91m") }
  it { should render(Hansi[:red], "foo").as("\e[91mfoo\e[0m") }
end