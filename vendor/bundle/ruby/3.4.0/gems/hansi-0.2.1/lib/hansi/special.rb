module Hansi
  class Special < AnsiCode
    def initialize(ansi, css = nil)
      ansi  = "\e[#{ansi}m" unless ansi.is_a? String and ansi.start_with? "\e"
      css   = css.map { |a| a.map { |v| Symbol === v ? v.to_s.tr('_','-') : v.to_s }.join(': ') } if css.is_a? Hash
      css   = css.join("; ") if css.is_a? Array
      css   = css + ";" if css and not css.end_with? ";"
      @ansi = ansi
      @css  = css
    end

    def to_css_rule
      @css || super
    end

    def to_ansi(mode: Hansi.mode, **options)
      mode &&= mode[/\d+/].to_i unless mode.is_a? Integer
      @ansi if mode > 1
    end

    def inspect
      "<%p:%p>" % [self.class, @ansi]
    end
  end
end
