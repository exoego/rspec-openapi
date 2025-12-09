require 'stringio'
require_relative '../test_helper'

module Optimist
  class ParserParseTest < ::Minitest::Test

  # TODO: parse
    # resolve_default_short_options!
    # parse_date_parameter
    # parse_integer_parameter(param, arg)
    # parse_float_parameter(param, arg)
    # parse_io_parameter(param, arg)
    # each_arg
      # collect_argument_parameters

  def test_help_needed
    parser.opt "arg"
    assert_raises(HelpNeeded) { parser.parse %w(-h) }
    assert_raises(HelpNeeded) { parser.parse %w(--help) }
  end

  def test_help_overridden
    parser.opt :arg1, "desc", :long => "help"
    assert parser.parse(%w(-h))[:arg1]
    assert parser.parse(%w(--help))[:arg1]
  end

  def test_help_with_other_args
    parser.opt :arg1
    assert_raises(HelpNeeded) { @p.parse %w(--arg1 --help) }
  end

  def test_help_with_arg_error
    parser.opt :arg1, :type => String
    assert_raises(HelpNeeded) { @p.parse %w(--arg1 --help) }
  end

  def test_version_needed_unset
    parser.opt "arg"
    assert_raises_errmatch(CommandlineError, /unknown argument '-v'/) { parser.parse %w(-v) }
  end

  def test_version_needed
    parser.version "optimist 5.2.3"
    assert_raises(VersionNeeded) { parser.parse %w(-v) }
    assert_raises(VersionNeeded) { parser.parse %w(--version) }
  end

  def test_version_overridden
    parser.opt "version"
    assert parser.parse(%w(-v))["version"]
    assert parser.parse(%w(-v))[:version_given]
  end

  def test_version_only_appears_if_set
    parser.opt "arg"
    assert_raises_errmatch(CommandlineError, /unknown argument '-v'/) { parser.parse %w(-v) }
  end

  def test_version_with_other_args
    parser.opt :arg1
    parser.version "1.1"
    assert_raises(VersionNeeded) { parser.parse %w(--arg1 --version) }
  end

  def test_version_with_arg_error
    parser.opt :arg1, :type => String
    parser.version "1.1"
    assert_raises(VersionNeeded) { parser.parse %w(--arg1 --version) }
  end


  private

    def parser
      @p ||= Parser.new
    end
  end
end
