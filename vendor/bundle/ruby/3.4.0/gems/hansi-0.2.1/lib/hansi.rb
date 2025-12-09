module Hansi
  TRUE_COLOR = 256**3

  def self.[](*args)
    ColorParser.parse(*args)
  end

  def self.mode
    @mode ||= mode_for(ENV)
  end

  def self.mode=(value)
    @mode = value
  end

  def self.mode_for(env, **options)
    ModeDetector.new(env, **options).mode
  end

  def self.render(*input, **options)
    renderer_for(input.first).render(*input, **options)
  end

  def self.renderer_for(input)
    case input
    when String        then StringRenderer
    when Symbol, Array then SexpRenderer
    when AnsiCode      then ColorRenderer
    else raise ArgumentError, "don't know how to render %p" % input
    end
  end

  def self.reset
    Hansi[:reset].to_ansi
  end

  def self.color_names
    PALETTES['web'].keys
  end

  require 'hansi/ansi_code'
  require 'hansi/color'
  require 'hansi/special'

  require 'hansi/color_parser'
  require 'hansi/color_renderer'
  require 'hansi/mode_detector'
  require 'hansi/palettes'
  require 'hansi/sexp_renderer'
  require 'hansi/string_renderer'
  require 'hansi/theme'
  require 'hansi/themes'
end
