module Hansi
  class AnsiCode
    def to_ansi_code(**options)
    end

    def to_css_rule
      "/* cannot convert #{inspect} to css */"
    end

    def to_css(*names, &block)
      block ||= -> key { ".#{key}" }
      name = names.map(&block).join(', ')
      "#{name} {\n  #{to_css_rule.gsub(/;\n?\s+(\S)/, ";\n  \\1")}\n}\n"
    end
  end
end
