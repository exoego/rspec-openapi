require 'strscan'

module Hansi
  class SexpRenderer
    def self.render(*args, **options)
      new(**options).render(args)
    end

    def initialize(theme: :default, mode: Hansi.mode, join: "")
      @theme = Theme[theme]
      @mode  = mode
      @join  = join
    end

    def render(input, codes: nil)
      return "#{codes}#{input}#{Hansi.reset}" unless input.respond_to? :to_ary and sexp = input.to_ary
      return render(sexp.first) if sexp.size < 2

      style, *content = sexp
      codes ||= Hansi.reset
      style &&= @theme[style]
      codes  += style.to_ansi(mode: @mode).to_s if style

      content.map { |e| render(e, codes: codes) }.join(@join)
    end
  end
end
