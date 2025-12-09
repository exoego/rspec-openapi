# frozen_string_literal: true

require "rouge/util"
require "rouge/token"
require "rouge/theme"
require "rouge/themes/gruvbox"
require "rouge/formatter"
require "rouge/formatters/terminal256"
require "rouge/lexer"
require "rouge/regex_lexer"
require "rouge/lexers/sql"

module Dry
  module Monitor
    module SQL
      module Colorizers
        class Rouge
          attr_reader :formatter, :lexer

          def initialize(theme)
            @formatter = ::Rouge::Formatters::Terminal256.new(theme || ::Rouge::Themes::Gruvbox.new)
            @lexer = ::Rouge::Lexers::SQL.new
          end

          def call(string)
            formatter.format(lexer.lex(string))
          end
        end
      end
    end
  end
end
