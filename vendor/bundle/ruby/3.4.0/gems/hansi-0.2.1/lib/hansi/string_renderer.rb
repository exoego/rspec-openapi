require 'strscan'

module Hansi
  class StringRenderer
    ParseError ||= Class.new(SyntaxError)

    def self.render(*args, **options)
      input, markup = [], {}

      args.each do |arg|
        if arg.respond_to? :to_hash
          markup.merge! arg.to_hash
        else
          input << arg
        end
      end

      new(markup, **options).render(*input)
    end

    def initialize(markup = {}, theme: :default, escape: ?\\, tags: false, mode: Hansi.mode)
      @theme    = Theme[theme]
      @escape   = escape
      @tags     = tags
      @markup   = markup
      @mode     = mode
      @simple   = Regexp.union(@markup.keys)
      reserved  = @markup.keys
      reserved += [?<, ?>] if @tags
      reserved << @escape if @escape
      @reserved = Regexp.union(reserved)
    end

    def render(input, *values)
      scanner = StringScanner.new(input)
      insert  = true
      stack   = []
      output  = String.new

      until scanner.eos?
        if scanner.scan(@simple)
          stack.last == scanner[0] ? stack.pop : stack.push(scanner[0])
          insert = true
        elsif @escape and scanner.scan(/#{Regexp.escape(@escape)}(.)/)
          output << color_codes(stack) if insert
          output << scanner[1]
          insert = false
        elsif @tags and scanner.scan(/<(\/)?([^>\s]+)>/)
          insert = true
          if scanner[1]
            unexpected(scanner[2], stack.last)
            stack.pop
          else
            stack << scanner[2]
          end
        else
          output << color_codes(stack) if insert
          output << scanner.getch
          insert = false
        end
      end

      unexpected(nil, stack.last)
      output << Hansi.reset
      values.any? ? output % values : output
    end

    def color_codes(stack)
      codes = [Hansi.reset, :default, *stack].map { |element| ansi_for(element) }
      codes.compact.join
    end

    def describe(element)
      case element
      when @simple then element.inspect
      when nil     then "end of string"
      else "</#{element}>".inspect
      end
    end

    def unexpected(element, expected)
      return if element == expected
      return if element == "#" and expected.start_with?("#")
      return if expected.start_with?("#{element}(") and expected.end_with?(")")
      raise ParseError, "unexpected #{describe(element)}, expecting #{describe(expected)}"
    end

    def ansi_for(input)
      case input
      when /^\e/         then input
      when *@markup.keys then ansi_for(@markup[input])
      when nil, false    then nil
      when AnsiCode      then input.to_ansi(mode: @mode)
      else ansi_for(@theme[input])
      end
    end

    def escape(string)
      return string unless @escape
      string.gsub(@reserved) { |s| "#{@escape}#{s}" }
    end
  end
end
