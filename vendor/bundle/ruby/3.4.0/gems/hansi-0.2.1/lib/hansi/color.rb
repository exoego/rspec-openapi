module Hansi
  class Color < AnsiCode
    attr_reader :red, :green, :blue, :distance_cache
    protected :distance_cache

    def initialize(red, green, blue)
      @red, @green, @blue = red, green, blue
      @distance_cache     = {}
    end

    def hash
      to_i.hash
    end

    def ==(other)
      other.class == self.class and other.to_i == self.to_i
    end

    def eql?(other)
      other.class.eql?(self.class) and other.to_i.eql?(self.to_i)
    end

    def distance(other)
      distance_cache[other.to_i] ||= other.distance_cache[to_i] || begin
        y1, u1, v1 = to_yuv
        y2, u2, v2 = other.to_yuv
        dy, du, dv = y1 - y2, u1 - u2, v1 - v2
        Math.sqrt(dy**2 + du**2 + dv**2)
      end
    end

    def closest(set)
      if set.respond_to? :to_hash
        hash = set.to_hash
        hash.key(closest(hash.values))
      elsif set.include? self
        self
      else
        set.grep(Color).min_by { |c| distance(c) }
      end
    end

    def to_yuv
      @yuv ||= begin
        y =  (0.257 * red) + (0.504 * green) + (0.098 * blue) + 16
        u = -(0.148 * red) - (0.291 * green) + (0.439 * blue) + 128
        v =  (0.439 * red) - (0.368 * green) - (0.071 * blue) + 128
        [y, u, v].freeze
      end
    end

    def to_i
      (red << 16) + (green << 8) + blue
    end

    def inspect
      "#<%p:%d,%d,%d>" % [self.class, red, green, blue]
    end

    def to_s
      "#%06x" % to_i
    end

    def to_css_rule
      "color: #{self};"
    end

    def to_ansi(mode: Hansi.mode, **options)
      case Integer === mode ? mode : Integer(mode.to_s[/\d+/])
      when 256            then to_ansi_256colors(**options)
      when 24, TRUE_COLOR then to_ansi_24bit(**options)
      when 88             then to_ansi_88colors(**options)
      when 16             then to_ansi_16colors(**options)
      when 8              then to_ansi_8colors(**options)
      when 1, 0           then ""
      else raise ArgumentError, "unknown mode %p" % mode
      end
    end

    def to_ansi_24bit(**options)
      "\e[38;2;%d;%d;%dm" % [red, green, blue]
    end

    def to_ansi_256colors(**options)
      from_palette('xterm-256color', 'xterm', **options)
    end

    def to_ansi_88colors(**options)
      from_palette('xterm-88color', 'xterm', **options)
    end

    def to_ansi_16colors(**options)
      from_palette('xterm', **options)
    end

    def to_ansi_8colors(**options)
      from_palette('ansi', **options)
    end

    def to_web_name(**options)
      from_palette('web', **options)
    end

    def from_palette(main, *fallback, exact: false)
      @from_palette ||= { true => {}, false => {} }
      cached          = @from_palette[exact]
      cached[main]  ||= PALETTES[main].key(self)
      cached[main]  ||= closest(PALETTES[main]) unless exact
      cached[main]  ||= from_palette(*fallback, exact: exact) if fallback.any?
      cached[main]
    end

    private :from_palette
  end
end
