require_relative '../test_helper'

module Optimist
  class CommandlineErrorTest < ::Minitest::Test
    def test_class
      assert_kind_of Exception, cle("message")
    end

    def test_message
      assert "message", cle("message").message
    end

    def test_error_code_default
      assert_nil cle("message").error_code
    end

    def test_error_code_custom
      assert_equal(-3, cle("message", -3).error_code)
    end

    private

    def cle(*args)
      CommandlineError.new(*args)
    end
  end
end
