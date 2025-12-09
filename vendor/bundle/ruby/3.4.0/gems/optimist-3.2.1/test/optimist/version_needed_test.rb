require_relative '../test_helper'

module Optimist
  class VersionNeededTest < ::Minitest::Test
    def test_class
      assert_kind_of Exception, vn("message")
    end

    def test_message
      assert "message", vn("message").message
    end

    private

    def vn(*args)
      VersionNeeded.new(*args)
    end
  end
end
