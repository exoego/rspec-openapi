module Hansi
  class Theme
    def self.[](key)
      case key
      when self   then key
      when Symbol then Themes.fetch(key)
      when Hash   then new(**key)
      when Array  then key.map { |k| self[k] }.inject(:merge)
      else raise ArgumentError, "cannot convert %p into a %p" % [key, self]
      end
    end

    def self.[]=(key, value)
      Themes[key.to_sym] = self[value]
    end

    attr_reader :rules
    def initialize(*inherit, **rules)
      inherited = inherit.map { |t| Theme[t].rules }.inject({}, :merge)
      @rules    = inherited.merge(rules).freeze
    end

    def ==(other)
      other.class == self.class and other.rules == self.rules
    end

    def eql?(other)
      other.class.eql?(self.class) and other.rules.eql?(self.rules)
    end

    def hash
      rules.hash
    end

    def [](key)
      return self[rules[key]]        if rules.include? key
      return self[rules[key.to_sym]] if key.respond_to? :to_sym and rules.include? key.to_sym
      ColorParser.parse(key)
    rescue ColorParser::IllegalValue
    end

    def merge(other)
      other_rules = self.class[other].rules
      self.class.new(**rules.merge(other_rules))
    end

    def to_h
      mapped = rules.keys.map { |key| [key, self[key]] if self[key] }
      Hash[mapped.compact]
    end

    def to_css(&block)
      mapping = rules.keys.group_by { |key| self[key] }
      mapping = mapping.map { |c,k| c.to_css(*k, &block) }
      mapping.compact.join(?\n)
    end

    def theme_name
      Themes.keys.detect { |key| Themes[key] == self }
    end

    def inspect
      "%p[%p]" % [self.class, theme_name || rules]
    end
  end
end
