module Hansi
  class ColorParser
    IllegalValue ||= Class.new(ArgumentError)
    singleton_class.send(:private, :new)

    def self.parse(*values)
      @parser ||= new
      @parser.parse(values)
    end

    def initialize
      @cache = {}
    end

    def parse(values, potentially_illegal: nil)
      @cache[values] ||= parse_values(values, potentially_illegal)
    end

    def parse_values(values, potentially_illegal)
      values = values.first while values.size == 1 and values.first.is_a? Array
      values = values.flat_map { |value| parse_value(value, potentially_illegal) }

      if values.size == 1 and values.first.is_a? AnsiCode
        values.first
      else
        values *= 3 if values.size == 1
        Color.new(*values)
      end
    end

    def parse_value(value, potentially_illegal)
      case value
      when Float    then parse_float(value,   potentially_illegal)
      when Integer  then parse_integer(value, potentially_illegal)
      when String   then parse_string(value,  potentially_illegal)
      when Hash     then parse_hash(potentially_illegal,  **value)
      when Symbol   then parse_symbol(value,  potentially_illegal)
      when AnsiCode then value
      else illegal(potentially_illegal || value)
      end
    end

    def parse_hash(potentially_illegal, red: 0, green: 0, blue: 0)
      [red, green, blue].map { |v| parse_value(v, potentially_illegal) }
    end

    def parse_color(color, potentially_illegal)
      [color.red, color.green, color.blue]
    end

    def parse_float(value, potentially_illegal)
      value *= 255 if value.between? 0, 1
      parse_integer(value.to_i, potentially_illegal || value)
    end
    
    def parse_integer(value, potentially_illegal)
      return value if value.between? 0, 255
      value > 255 ? 255 : 0
    end

    def parse_string(string, potentially_illegal)
      return parse_ansi(string, potentially_illegal || string) if string.start_with? ?\e
      return parse_hash(potentially_illegal || string, red: $1.to_i, green: $2.to_i, blue: $3.to_i) if string =~ /^rgb\((\d{1,3}),(\d{1,3}),(\d{1,3})\)$/m
      return parse_symbol(string, potentially_illegal || string) if string !~ /^#?[0-9a-f]+$/
      string = string[1..-1] if string.start_with?(?#)
      case string.size
      when 1 then (string*2).to_i(16)
      when 2 then string.to_i(16)
      when 3 then string.each_char.map { |c| (c*2).to_i(16) }
      when 6 then [string[0,2].to_i(16), string[2,2].to_i(16), string[4,2].to_i(16)]
      else illegal(potentially_illegal || string)
      end
    end

    def parse_ansi(string, potentially_illegal)
      case string
      when /\e\[(?:\d;)?38;2;(\d{1,3});(\d{1,3});(\d{1,3})(?:;\d)?m/ then parse_hash(potentially_illegal, red: $1.to_i, green: $2.to_i, blue: $3.to_i)
      when /\e\[(?:\d;)?38;5;(\d{1,3})(?:;\d)?m/                     then parse_color(PALETTES[ 'xterm-256color' ].fetch("\e[38;5;#{$1.to_i}m") { illegal(potentially_illegal) }, potentially_illegal)
      when /\e\[(?:\d;)?([39]\d)(?:;\d)?m/                           then parse_color(PALETTES[ 'xterm'          ].fetch("\e[#{$1}m")           { illegal(potentially_illegal) }, potentially_illegal)
      end
    end

    def parse_symbol(symbol, potentially_illegal)
      value = symbol.to_s.downcase.gsub(/[^a-z]/, '').to_sym
      value = PALETTES['special'][value] || PALETTES['web'][value]
      parse_value(value, potentially_illegal || symbol)
    end

    def illegal(value)
      raise IllegalValue, 'illegal color value %p' % value
    end
  end
end
