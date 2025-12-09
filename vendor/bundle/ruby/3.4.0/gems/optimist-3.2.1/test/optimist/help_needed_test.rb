require_relative '../test_helper'

module Optimist
  class HelpNeededTest < ::Minitest::Test
    def test_class
      assert_kind_of Exception, hn("message")
    end

    def test_message
      assert "message", hn("message").message
    end

    private

    def hn(*args)
      HelpNeeded.new(*args)
    end
  end
end
