require 'stringio'
require_relative '../test_helper'

module Optimist

class ParserPermittedTest < ::Minitest::Test
  def setup
    @p = Parser.new
  end

  def test_permitted_flags_filter_inputs
    @p.opt "arg", "desc", :type => :strings, :permitted => %w(foo bar)

    result = @p.parse(%w(--arg foo))
    assert_equal ["foo"], result["arg"]
    assert_raises_errmatch(CommandlineError, /option '--arg' only accepts one of: foo, bar/) { @p.parse(%w(--arg baz)) }
  end

  def test_permitted_invalid_scalar_value
    err_regexp = /permitted values for option "(bad|mad|sad)" must be either nil, Range, Regexp or an Array/
    assert_raises_errmatch(ArgumentError, err_regexp) {
      @p.opt 'bad', 'desc', :permitted => 1
    }
    assert_raises_errmatch(ArgumentError, err_regexp) {
      @p.opt 'mad', 'desc', :permitted => "A"
    }
    assert_raises_errmatch(ArgumentError, err_regexp) {
      @p.opt 'sad', 'desc', :permitted => :abcd
    }
  end

  def test_permitted_with_string_array
    @p.opt 'fiz', 'desc', :type => 'string', :permitted => ['foo', 'bar']
    @p.parse(%w(--fiz foo))
    assert_raises_errmatch(CommandlineError, /option '--fiz' only accepts one of: foo, bar/) {
      @p.parse(%w(--fiz buz))
    }
  end
  def test_permitted_with_symbol_array
    @p.opt 'fiz', 'desc', :type => 'string', :permitted => %i[dog cat]
    @p.parse(%w(--fiz dog))
    @p.parse(%w(--fiz cat))
    assert_raises_errmatch(CommandlineError, /option '--fiz' only accepts one of: dog, cat/) {
      @p.parse(%w(--fiz rat))
    }
  end

  def test_permitted_with_numeric_array
    @p.opt 'mynum', 'desc', :type => Integer, :permitted => [1,2,4]
    @p.parse(%w(--mynum 1))
    @p.parse(%w(--mynum 4))
    assert_raises_errmatch(CommandlineError, /option '--mynum' only accepts one of: 1, 2, 4/) {
      @p.parse(%w(--mynum 3))
    }
  end

  def test_permitted_with_string_range
    @p.opt 'fiz', 'desc', :type => String, :permitted => 'A'..'z'
    opts = @p.parse(%w(--fiz B))
    assert_equal opts['fiz'], "B"
    opts = @p.parse(%w(--fiz z))
    assert_equal opts['fiz'], "z"
    assert_raises_errmatch(CommandlineError, /option '--fiz' only accepts value in range of: A\.\.z/) {
      @p.parse(%w(--fiz @))
    }
  end

  def test_permitted_with_integer_range
    @p.opt 'fiz', 'desc', :type => Integer, :permitted => 1..3
    opts = @p.parse(%w(--fiz 1))
    assert_equal opts['fiz'], 1
    opts = @p.parse(%w(--fiz 3))
    assert_equal opts['fiz'], 3
    assert_raises_errmatch(CommandlineError, /option '--fiz' only accepts value in range of: 1\.\.3/) {
      @p.parse(%w(--fiz 4))
    }
  end

  def test_permitted_with_float_range
    @p.opt 'fiz', 'desc', :type => Float, :permitted => 1.2 .. 3.5
    opts = @p.parse(%w(--fiz 1.2))
    assert_in_epsilon opts['fiz'], 1.2
    opts = @p.parse(%w(--fiz 2.7))
    assert_in_epsilon opts['fiz'], 2.7
    opts = @p.parse(%w(--fiz 3.5))
    assert_in_epsilon opts['fiz'], 3.5
    err_regexp = /option '--fiz' only accepts value in range of: 1\.2\.\.3\.5/
    assert_raises_errmatch(CommandlineError, err_regexp) {
      @p.parse(%w(--fiz 3.51))
    }
    assert_raises_errmatch(CommandlineError, err_regexp) {
      @p.parse(%w(--fiz 1.19))
    }
  end

  def test_permitted_with_regexp
    @p.opt 'zipcode', 'desc', :type => String, :permitted => /^[0-9]{5}$/
    @p.parse(%w(--zipcode 39762))
    err_regexp = %r|option '--zipcode' only accepts value matching: /\^\[0-9\]\{5\}\$/|
    assert_raises_errmatch(CommandlineError, err_regexp) {
      @p.parse(%w(--zipcode A9A9AA))
    }
  end
  def test_permitted_with_reason
    # test all keys passed into the formatter for the permitted_response
    @p.opt 'zipcode', 'desc', type: String, permitted: /^[0-9]{5}$/,
           permitted_response: "opt %{arg} should be a zipcode but you have %{value}"
    @p.opt :wig, 'wig', type: Integer, permitted: 1..4,
           permitted_response: "opt %{arg} exceeded four wigs (%{valid_string}), %{permitted}, but you gave '%{given}'"
    err_regexp = %r|opt --zipcode should be a zipcode but you have A9A9AA|
    assert_raises_errmatch(CommandlineError, err_regexp) {
      @p.parse(%w(--zipcode A9A9AA))
    }
    err_regexp = %r|opt --wig exceeded four wigs \(value in range of: 1\.\.4\), 1\.\.4, but you gave '5'|
    assert_raises_errmatch(CommandlineError, err_regexp) {
      @p.parse(%w(--wig 5))
    }
  end

end
end
