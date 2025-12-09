require 'stringio'
require_relative '../test_helper'

module Optimist

  class ParserOptTest < ::Minitest::Test

    private

    def parser
      @p ||= Parser.new
    end
  end
end
