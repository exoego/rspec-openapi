require 'strscan'

module Hansi
  class ColorRenderer
    def self.render(*input, **options)
      new(**options).render(*input)
    end

    def initialize(mode: Hansi.mode, join: "")
      @mode  = mode
      @join  = join
    end

    def render(color, *input)
      output  = color.to_ansi(mode: @mode)
      output += input.join(@join) + Hansi.reset if input.any?
      output
    end
  end
end
