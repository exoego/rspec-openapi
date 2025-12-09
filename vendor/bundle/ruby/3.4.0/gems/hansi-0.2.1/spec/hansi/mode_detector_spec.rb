describe Hansi::ModeDetector do
  example do
    detector = Hansi::ModeDetector.new(ENV)
    expect(detector)      .to be_shell_out
    expect(detector.io)   .to be == $stdout
    expect(detector.mode) .to be_an(Integer)
  end

  example do
    detector = Hansi::ModeDetector.new({})
    expect(detector)      .not_to be_shell_out
    expect(detector.io)   .to     be_nil
    expect(detector.mode) .to     be == 0
  end

  example do
    detector = Hansi::ModeDetector.new({'TERM' => 'xterm'})
    expect(detector.mode).to be == 16
  end

  example do
    detector = Hansi::ModeDetector.new({'TERM' => 'footerm-256color'})
    expect(detector.mode).to be == 256
  end

  example do
    detector = Hansi::ModeDetector.new({'TERM' => 'footerm+24bit'})
    expect(detector.mode).to be == Hansi::TRUE_COLOR
  end

  example do
    detector = Hansi::ModeDetector.new({'TERM' => 'footerm+3byte'})
    expect(detector.mode).to be == Hansi::TRUE_COLOR
  end
end