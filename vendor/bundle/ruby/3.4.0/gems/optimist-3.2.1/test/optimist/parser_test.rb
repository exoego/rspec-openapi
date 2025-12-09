require 'stringio'
require_relative '../test_helper'

module Optimist

class ParserTest < ::Minitest::Test
  def setup
    @p = Parser.new
  end

  def parser
    @p ||= Parser.new
  end

  # initialize
  # cloaker

  def test_version
    assert_nil parser.version
    assert_equal "optimist 5.2.3", parser.version("optimist 5.2.3")
    assert_equal "optimist 5.2.3", parser.version
  end

  def test_usage
    assert_nil parser.usage

    assert_equal "usage string", parser.usage("usage string")
    assert_equal "usage string", parser.usage
  end

  def test_synopsis
    assert_nil parser.synopsis

    assert_equal "synopsis string", parser.synopsis("synopsis string")
    assert_equal "synopsis string", parser.synopsis
  end

  # def test_stop_on
  # def test_stop_on_unknown

  # die
  # def test_die_educate_on_error


  def test_unknown_arguments
    assert_raises_errmatch(CommandlineError, /unknown argument '--arg'/) { @p.parse(%w(--arg)) }
    @p.opt "arg"
    @p.parse(%w(--arg))
    assert_raises_errmatch(CommandlineError, /unknown argument '--arg2'/) { @p.parse(%w(--arg2)) }
  end

  def test_unknown_arguments_with_suggestions
    unless (Module::const_defined?("DidYouMean") &&
      Module::const_defined?("DidYouMean::JaroWinkler") &&
      Module::const_defined?("DidYouMean::Levenshtein"))
      # if we cannot
      skip("Skipping because DidYouMean was not found")
      return false
    end
    sugp = Parser.new(:suggestions => true)
    err = assert_raises(CommandlineError) { sugp.parse(%w(--bone)) }
    assert_match(/unknown argument '--bone'$/, err.message)

    sugp.opt "cone"
    sugp.parse(%w(--cone))

    # single letter mismatch
    err = assert_raises(CommandlineError) { sugp.parse(%w(--bone)) }
    assert_match(/unknown argument '--bone'.  Did you mean: \[--cone\] \?$/, err.message)

    # transposition
    err = assert_raises(CommandlineError) { sugp.parse(%w(--ocne)) }
    assert_match(/unknown argument '--ocne'.  Did you mean: \[--cone\] \?$/, err.message)

    # extra letter at end
    err = assert_raises(CommandlineError) { sugp.parse(%w(--cones)) }
    assert_match(/unknown argument '--cones'.  Did you mean: \[--cone\] \?$/, err.message)

    # too big of a mismatch to suggest (extra letters in front)
    err = assert_raises(CommandlineError) { sugp.parse(%w(--snowcone)) }
    assert_match(/unknown argument '--snowcone'$/, err.message)

    # too big of a mismatch to suggest (nothing close)
    err = assert_raises(CommandlineError) { sugp.parse(%w(--clown-nose)) }
    assert_match(/unknown argument '--clown-nose'$/, err.message)

    sugp.opt "zippy"
    sugp.opt "zapzy"
    # single letter mismatch, matches two
    err = assert_raises(CommandlineError) { sugp.parse(%w(--zipzy)) }
    assert_match(/unknown argument '--zipzy'.  Did you mean: \[--zippy, --zapzy\] \?$/, err.message)

    sugp.opt "big_bug"
    # suggest common case of dash versus underscore in argnames
    err = assert_raises(CommandlineError) { sugp.parse(%w(--big_bug)) }
    assert_match(/unknown argument '--big_bug'.  Did you mean: \[--big-bug\] \?$/, err.message)
  end

  def test_syntax_check
    @p.opt "arg"

    @p.parse(%w(--arg))
    @p.parse(%w(arg))
    assert_raises_errmatch(CommandlineError, /invalid argument syntax: '---arg'/) { @p.parse(%w(---arg)) }
    assert_raises_errmatch(CommandlineError, /unknown argument '-r'/) { @p.parse(%w(-arg)) }
  end

  def test_required_flags_are_required
    @p.opt "arg", "desc", :required => true
    @p.opt "arg2", "desc", :required => false
    @p.opt "arg3", "desc", :required => false

    @p.parse(%w(--arg))
    @p.parse(%w(--arg --arg2))
    err_regex = %r/option --arg must be specified/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--arg2)) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--arg2 --arg3)) }
  end

  ## flags that take an argument error unless given one
  def test_argflags_demand_args
    @p.opt "goodarg", "desc", :type => String
    @p.opt "goodarg2", "desc", :type => String

    @p.parse(%w(--goodarg goat))
    err_regex = %r/option '--goodarg' needs a parameter/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--goodarg --goodarg2 goat)) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--goodarg)) }
  end

  ## flags that don't take arguments ignore them
  def test_arglessflags_refuse_args
    @p.opt "goodarg"
    @p.opt "goodarg2"
    @p.parse(%w(--goodarg))
    @p.parse(%w(--goodarg --goodarg2))
    opts = @p.parse %w(--goodarg a)
    assert_equal true, opts["goodarg"]
    assert_equal ["a"], @p.leftovers
  end

  ## flags that require args of a specific type refuse args of other
  ## types
  def test_typed_args_refuse_args_of_other_types
    @p.opt "goodarg", "desc", :type => :int
    err_regex = %r/Unsupported argument type 'asdf', registry lookup 'asdf'/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :type => :asdf }

    @p.parse(%w(--goodarg 3))
    err_regex = %r/option 'goodarg' needs an integer/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--goodarg 4.2)) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--goodarg hello)) }
  end

  ## type is correctly derived from :default
  def test_type_correctly_derived_from_default
    err_regex = %r/multiple argument type cannot be deduced from an empty array/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :default => [] }
    err_regex = %r/Unsupported argument type 'hashs', registry lookup 'hashs'/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg3", "desc", :default => [{1 => 2}] }
    err_regex = %r/Unsupported argument type 'hash', registry lookup 'hash'/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg4", "desc", :default => Hash.new }

    # single arg: int
    @p.opt "argsi", "desc", :default => 0
    opts = @p.parse(%w(--))
    assert_equal 0, opts["argsi"]
    opts = @p.parse(%w(--argsi 4))
    assert_equal 4, opts["argsi"]
    opts = @p.parse(%w(--argsi=4))
    assert_equal 4, opts["argsi"]
    opts = @p.parse(%w(--argsi=-4))
    assert_equal( -4, opts["argsi"])
    err_regex = /option 'argsi' needs an integer/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argsi 4.2)) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argsi hello)) }

    # single arg: float
    @p.opt "argsf", "desc", :default => 3.14
    opts = @p.parse(%w(--))
    assert_equal 3.14, opts["argsf"]
    opts = @p.parse(%w(--argsf 2.41))
    assert_equal 2.41, opts["argsf"]
    opts = @p.parse(%w(--argsf 2))
    assert_equal 2, opts["argsf"]
    opts = @p.parse(%w(--argsf 1.0e-2))
    assert_equal 1.0e-2, opts["argsf"]
    err_regex = /option 'argsf' needs a floating-point number/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argsf hello)) }

    # single arg: date
    date = Date.today
    @p.opt "argsd", "desc", :default => date
    opts = @p.parse(%w(--))
    assert_equal Date.today, opts["argsd"]
    opts = @p.parse(['--argsd', 'Jan 4, 2007'])
    assert_equal Date.civil(2007, 1, 4), opts["argsd"]
    err_regex = /option 'argsd' needs a date/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argsd hello)) }

    # single arg: string
    @p.opt "argss", "desc", :default => "foobar"
    opts = @p.parse(%w(--))
    assert_equal "foobar", opts["argss"]
    opts = @p.parse(%w(--argss 2.41))
    assert_equal "2.41", opts["argss"]
    opts = @p.parse(%w(--argss hello))
    assert_equal "hello", opts["argss"]

    # multi args: ints
    @p.opt "argmi", "desc", :default => [3, 5]
    opts = @p.parse(%w(--))
    assert_equal [3, 5], opts["argmi"]
    opts = @p.parse(%w(--argmi 4))
    assert_equal [4], opts["argmi"]
    err_regex = /option 'argmi' needs an integer/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argmi 4.2)) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argmi hello)) }

    # multi args: floats
    @p.opt "argmf", "desc", :default => [3.34, 5.21]
    opts = @p.parse(%w(--))
    assert_equal [3.34, 5.21], opts["argmf"]
    opts = @p.parse(%w(--argmf 2))
    assert_equal [2], opts["argmf"]
    opts = @p.parse(%w(--argmf 4.0))
    assert_equal [4.0], opts["argmf"]
    err_regex = /option 'argmf' needs a floating-point number/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argmf hello)) }

    # multi args: dates
    dates = [Date.today, Date.civil(2007, 1, 4)]
    @p.opt "argmd", "desc", :default => dates
    opts = @p.parse(%w(--))
    assert_equal dates, opts["argmd"]
    opts = @p.parse(['--argmd', 'Jan 4, 2007'])
    assert_equal [Date.civil(2007, 1, 4)], opts["argmd"]
    err_regex = /option 'argmd' needs a date/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse(%w(--argmd hello)) }

    # multi args: strings
    @p.opt "argmst", "desc", :default => %w(hello world)
    opts = @p.parse(%w(--))
    assert_equal %w(hello world), opts["argmst"]
    opts = @p.parse(%w(--argmst 3.4))
    assert_equal ["3.4"], opts["argmst"]
    opts = @p.parse(%w(--argmst goodbye))
    assert_equal ["goodbye"], opts["argmst"]
  end

  ## :type and :default must match if both are specified
  def test_type_and_default_must_match
    # Different versions of ruby raise different error messages.
    err_regex = %r/(type specification and default type don't match|Unsupported argument type)/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :type => :int, :default => "hello" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg2", "desc", :type => :String, :default => 4 }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg2", "desc", :type => :String, :default => ["hi"] }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg2", "desc", :type => :ints, :default => [3.14] }

    @p.opt "argsi", "desc", :type => :int, :default => 4
    @p.opt "argsf", "desc", :type => :float, :default => 3.14
    @p.opt "argsd", "desc", :type => :date, :default => Date.today
    @p.opt "argss", "desc", :type => :string, :default => "yo"
    @p.opt "argmi", "desc", :type => :ints, :default => [4]
    @p.opt "argmf", "desc", :type => :floats, :default => [3.14]
    @p.opt "argmd", "desc", :type => :dates, :default => [Date.today]
    @p.opt "argmst", "desc", :type => :strings, :default => ["yo"]
  end

  ##
  def test_flags_with_defaults_and_no_args_act_as_switches
    @p.opt :argd, "desc", :default => "default_string"

    opts = @p.parse(%w(--))
    assert !opts[:argd_given]
    assert_equal "default_string", opts[:argd]

    opts = @p.parse(%w( --argd ))
    assert opts[:argd_given]
    assert_equal "default_string", opts[:argd]

    opts = @p.parse(%w(--argd different_string))
    assert opts[:argd_given]
    assert_equal "different_string", opts[:argd]
  end

  def test_flag_with_no_defaults_and_no_args_act_as_switches_array
    opts = nil

    @p.opt :argd, "desc", :type => :strings, :default => ["default_string"]

    opts = @p.parse(%w(--argd))
    assert_equal ["default_string"], opts[:argd]
  end

  def test_type_and_empty_array
    @p.opt "argmi", "desc", :type => :ints, :default => []
    @p.opt "argmf", "desc", :type => :floats, :default => []
    @p.opt "argmd", "desc", :type => :dates, :default => []
    @p.opt "argms", "desc", :type => :strings, :default => []
    err_regex = %r/multiple argument type must be plural/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badi", "desc", :type => :int, :default => [] }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badf", "desc", :type => :float, :default => [] }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badd", "desc", :type => :date, :default => [] }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "bads", "desc", :type => :string, :default => [] }
    opts = @p.parse([])
    assert_equal(opts["argmi"], [])
    assert_equal(opts["argmf"], [])
    assert_equal(opts["argmd"], [])
    assert_equal(opts["argms"], [])
  end

  def test_long_detects_bad_names
    @p.opt "goodarg", "desc", :long => "none"
    @p.opt "goodarg2", "desc", :long => "--two"
    @p.opt "goodarg3", "desc", :long => "arg-3"
    @p.opt "goodarg4", "desc", :long => "--good-arg-four"
    err_regex = /invalid long option name/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :long => "" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg2", "desc", :long => "--" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg3", "desc", :long => "-one" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg4", "desc", :long => "---toomany" }
  end

  def test_short_detects_bad_names
    @p.opt "goodarg", "desc", :short => "a"
    @p.opt "goodarg2", "desc", :short => "-b"
    err_regex = /invalid short option name/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :short => "" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg2", "desc", :short => "-ab" }
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg3", "desc", :short => "--t" }
  end

  def test_short_names_created_automatically
    @p.opt "arg"
    @p.opt "arg2"
    @p.opt "arg3"
    opts = @p.parse %w(-a -g)
    assert_equal true, opts["arg"]
    assert_equal false, opts["arg2"]
    assert_equal true, opts["arg3"]
  end

  def test_short_autocreation_skips_dashes_and_numbers
    @p.opt :arg # auto: a
    @p.opt :arg_potato # auto: r
    @p.opt :arg_muffin # auto: g
    @p.opt :arg_daisy  # auto: d (not _)!
    @p.opt :arg_r2d2f  # auto: f (not 2)!

    opts = @p.parse %w(-f -d)
    assert_equal true, opts[:arg_daisy]
    assert_equal true, opts[:arg_r2d2f]
    assert_equal false, opts[:arg]
    assert_equal false, opts[:arg_potato]
    assert_equal false, opts[:arg_muffin]
  end

  def test_short_autocreation_is_ok_with_running_out_of_chars
    @p.opt :arg1 # auto: a
    @p.opt :arg2 # auto: r
    @p.opt :arg3 # auto: g
    @p.opt :arg4 # auto: uh oh!
    @p.parse []
  end

  def test_short_can_be_nothing
    @p.opt "arg", "desc", :short => :none
    @p.parse []

    sio = StringIO.new
    @p.educate sio
    assert sio.string =~ /--arg\s+desc/

    assert_raises_errmatch(CommandlineError, /unknown argument '-a'/) { @p.parse %w(-a) }
  end

  ## two args can't have the same name
  def test_conflicting_names_are_detected
    @p.opt "goodarg"
    err_regex = /you already have an argument named 'goodarg'/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "goodarg" }
  end

  ## two args can't have the same :long
  def test_conflicting_longs_detected
    @p.opt "goodarg", "desc", :long => "--goodarg"
    err_regex = /long option name \"goodarg\" is already taken/

    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :long => "--goodarg" }
  end

  ## two args can't have the same :short
  def test_conflicting_shorts_detected
    @p.opt "goodarg", "desc", :short => "-g"
    err_regex = /short option name \"g\" is already taken/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt "badarg", "desc", :short => "-g" }
  end

  ## note: this behavior has changed in optimist 2.0!
  def test_flag_parameters
    @p.opt :defaultnone, "desc"
    @p.opt :defaultfalse, "desc", :default => false
    @p.opt :defaulttrue, "desc", :default => true

    ## default state
    opts = @p.parse []
    assert_equal false, opts[:defaultnone]
    assert_equal false, opts[:defaultfalse]
    assert_equal true, opts[:defaulttrue]

    ## specifying turns them on, regardless of default
    opts = @p.parse %w(--defaultfalse --defaulttrue --defaultnone)
    assert_equal true, opts[:defaultnone]
    assert_equal true, opts[:defaultfalse]
    assert_equal true, opts[:defaulttrue]

    ## using short form turns them all on, regardless of default
    #
    # (matches positve "non-no" long form)
    opts = @p.parse %w(-d -e -f)
    assert_equal true, opts[:defaultnone]
    assert_equal true, opts[:defaultfalse]
    assert_equal true, opts[:defaulttrue]

    ## using --no- form turns them off, regardless of default
    opts = @p.parse %w(--no-defaultfalse --no-defaulttrue --no-defaultnone)
    assert_equal false, opts[:defaultnone]
    assert_equal false, opts[:defaultfalse]
    assert_equal false, opts[:defaulttrue]
  end

  ## note: this behavior has changed in optimist 2.0!
  def test_flag_parameters_for_inverted_flags
    @p.opt :no_default_none, "desc"
    @p.opt :no_default_false, "desc", :default => false
    @p.opt :no_default_true, "desc", :default => true

    ## default state
    opts = @p.parse []
    assert_equal false, opts[:no_default_none]
    assert_equal false, opts[:no_default_false]
    assert_equal true, opts[:no_default_true]

    ## specifying turns them all on, regardless of default
    opts = @p.parse %w(--no-default-false --no-default-true --no-default-none)
    assert_equal true, opts[:no_default_none]
    assert_equal true, opts[:no_default_false]
    assert_equal true, opts[:no_default_true]

    ## using dropped-no form turns them all off, regardless of default
    opts = @p.parse %w(--default-false --default-true --default-none)
    assert_equal false, opts[:no_default_none]
    assert_equal false, opts[:no_default_false]
    assert_equal false, opts[:no_default_true]

    ## using short form turns them all off, regardless of default
    #
    # (matches positve "non-no" long form)
    opts = @p.parse %w(-n -o -d)
    assert_equal false, opts[:no_default_none]
    assert_equal false, opts[:no_default_false]
    assert_equal false, opts[:no_default_true]

    ## disallow double negatives for reasons of sanity preservation
    assert_raises_errmatch(CommandlineError, /unknown argument '--no-default-true'/) { @p.parse %w(--no-no-default-true) }
  end

  def test_short_options_combine
    @p.opt :arg1, "desc", :short => "a"
    @p.opt :arg2, "desc", :short => "b"
    @p.opt :arg3, "desc", :short => "c", :type => :int

    opts = @p.parse %w(-a -b)
    assert_equal true, opts[:arg1]
    assert_equal true, opts[:arg2]
    assert_nil opts[:arg3]

    opts = @p.parse %w(-ab)
    assert_equal true, opts[:arg1]
    assert_equal true, opts[:arg2]
    assert_nil opts[:arg3]

    opts = @p.parse %w(-ac 4 -b)
    assert_equal true, opts[:arg1]
    assert_equal true, opts[:arg2]
    assert_equal 4, opts[:arg3]

    err_regex = /option '-c' needs a parameter/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-cab 4) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-cba 4) }
  end

  def test_doubledash_ends_option_processing
    @p.opt :arg1, "desc", :short => "a", :default => 0
    @p.opt :arg2, "desc", :short => "b", :default => 0
    opts = @p.parse %w(-- -a 3 -b 2)
    assert_equal opts[:arg1], 0
    assert_equal opts[:arg2], 0
    assert_equal %w(-a 3 -b 2), @p.leftovers
    opts = @p.parse %w(-a 3 -- -b 2)
    assert_equal opts[:arg1], 3
    assert_equal opts[:arg2], 0
    assert_equal %w(-b 2), @p.leftovers
    opts = @p.parse %w(-a 3 -b 2 --)
    assert_equal opts[:arg1], 3
    assert_equal opts[:arg2], 2
    assert_equal %w(), @p.leftovers
  end

  def test_wrap
    assert_equal [""], @p.wrap("")
    assert_equal ["a"], @p.wrap("a")
    assert_equal ["one two", "three"], @p.wrap("one two three", :width => 8)
    assert_equal ["one two three"], @p.wrap("one two three", :width => 80)
    assert_equal ["one", "two", "three"], @p.wrap("one two three", :width => 3)
    assert_equal ["onetwothree"], @p.wrap("onetwothree", :width => 3)
    assert_equal [
      "Test is an awesome program that does something very, very important.",
      "",
      "Usage:",
      "  test [options] <filenames>+",
      "where [options] are:"], @p.wrap(<<EOM, :width => 100)
Test is an awesome program that does something very, very important.

Usage:
  test [options] <filenames>+
where [options] are:
EOM
  end

  def test_multi_line_description
    out = StringIO.new
    @p.opt :arg, <<-EOM, :type => :int
This is an arg
with a multi-line description
    EOM
    @p.educate(out)
    assert_equal <<-EOM, out.string
Options:
  --arg=<i>    This is an arg
               with a multi-line description
    EOM
  end

  def test_integer_formatting
    @p.opt :arg, "desc", :type => :integer, :short => "i"
    opts = @p.parse %w(-i 5)
    assert_equal 5, opts[:arg]
  end

  def test_integer_formatting_default
    @p.opt :arg, "desc", :type => :integer, :short => "i", :default => 3
    opts = @p.parse %w(-i)
    assert_equal 3, opts[:arg]
  end

  def test_floating_point_formatting
    @p.opt :arg, "desc", :type => :float, :short => "f"
    opts = @p.parse %w(-f 1)
    assert_equal 1.0, opts[:arg]
    opts = @p.parse %w(-f 1.0)
    assert_equal 1.0, opts[:arg]
    opts = @p.parse %w(-f 0.1)
    assert_equal 0.1, opts[:arg]
    opts = @p.parse %w(-f .1)
    assert_equal 0.1, opts[:arg]
    opts = @p.parse %w(-f .99999999999999999999)
    assert_equal 1.0, opts[:arg]
    opts = @p.parse %w(-f -1)
    assert_equal(-1.0, opts[:arg])
    opts = @p.parse %w(-f -1.0)
    assert_equal(-1.0, opts[:arg])
    opts = @p.parse %w(-f -0.1)
    assert_equal(-0.1, opts[:arg])
    opts = @p.parse %w(-f -.1)
    assert_equal(-0.1, opts[:arg])
    err_regex = %r/option 'arg' needs a floating-point number/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f a) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f 1a) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f 1.a) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f a.1) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f 1.0.0) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f .) }
    err_regex = %r/unknown argument '-.'/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-f -.) }
  end

  def test_floating_point_formatting_default
    @p.opt :arg, "desc", :type => :float, :short => "f", :default => 5.5
    opts = @p.parse %w(-f)
    assert_equal 5.5, opts[:arg]
  end

  def test_date_formatting
    @p.opt :arg, "desc", :type => :date, :short => 'd'
    opts = @p.parse(['-d', 'Jan 4, 2007'])
    assert_equal Date.civil(2007, 1, 4), opts[:arg]
    opts = @p.parse(['-d', 'today'])
    assert_equal Date.today, opts[:arg]
  end

  def test_short_options_cant_be_numeric
    err_regex = %r/short option name '1' can't be a number or a dash/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt :arg, "desc", :short => "-1" }
    @p.opt :a1b, "desc"
    @p.opt :a2b, "desc"
    @p.parse []
    # testing private interface to ensure default
    # short options did not become numeric
    assert_equal @p.specs[:a1b].short.chars.first, 'a'
    assert_equal @p.specs[:a2b].short.chars.first, 'b'
  end

  def test_short_options_can_be_weird
    @p.opt :arg1, "desc", :short => "#"
    @p.opt :arg2, "desc", :short => "."
    err_regex = %r/short option name '-' can't be a number or a dash/
    assert_raises_errmatch(ArgumentError, err_regex) { @p.opt :arg3, "desc", :short => "-" }
  end

  def test_options_cant_be_set_multiple_times_if_not_specified
    @p.opt :arg, "desc", :short => "-x"
    @p.parse %w(-x)
    err_regex = /option '-x' specified multiple times/
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-x -x) }
    assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-xx) }
  end

  def test_options_can_be_set_multiple_times_if_specified
    @p.opt :arg, "desc", :short => "-x", :multi => true
    @p.parse %w(-x)
    @p.parse %w(-x -x)
    @p.parse %w(-xx)
  end

  def test_short_options_with_multiple_options
    @p.opt :xarg, "desc", :short => "-x", :type => String, :multi => true
    opts = @p.parse %w(-x a -x b)
    assert_equal %w(a b), opts[:xarg]
    assert_equal [], @p.leftovers
  end

  def test_short_options_with_multiple_options_does_not_affect_flags_type
    @p.opt :xarg, "desc", :short => "-x", :type => :flag, :multi => true

    opts = @p.parse %w(-x a)
    assert_equal true, opts[:xarg]
    assert_equal %w(a), @p.leftovers

    opts = @p.parse %w(-x a -x b)
    assert_equal true, opts[:xarg]
    assert_equal %w(a b), @p.leftovers

    opts = @p.parse %w(-xx a -x b)
    assert_equal true, opts[:xarg]
    assert_equal %w(a b), @p.leftovers
  end

  def test_short_options_with_multiple_arguments
    @p.opt :xarg, "desc", :type => :ints
    opts = @p.parse %w(-x 3 4 0)
    assert_equal [3, 4, 0], opts[:xarg]
    assert_equal [], @p.leftovers

    @p.opt :yarg, "desc", :type => :floats
    opts = @p.parse %w(-y 3.14 4.21 0.66)
    assert_equal [3.14, 4.21, 0.66], opts[:yarg]
    assert_equal [], @p.leftovers

    @p.opt :zarg, "desc", :type => :strings
    opts = @p.parse %w(-z a b c)
    assert_equal %w(a b c), opts[:zarg]
    assert_equal [], @p.leftovers
  end

  def test_short_options_with_multiple_options_and_arguments
    @p.opt :xarg, "desc", :type => :ints, :multi => true
    opts = @p.parse %w(-x 3 4 5 -x 6 7)
    assert_equal [[3, 4, 5], [6, 7]], opts[:xarg]
    assert_equal [], @p.leftovers

    @p.opt :yarg, "desc", :type => :floats, :multi => true
    opts = @p.parse %w(-y 3.14 4.21 5.66 -y 6.99 7.01)
    assert_equal [[3.14, 4.21, 5.66], [6.99, 7.01]], opts[:yarg]
    assert_equal [], @p.leftovers

    @p.opt :zarg, "desc", :type => :strings, :multi => true
    opts = @p.parse %w(-z a b c -z d e)
    assert_equal [%w(a b c), %w(d e)], opts[:zarg]
    assert_equal [], @p.leftovers
  end

  def test_combined_short_options_with_multiple_arguments
    @p.opt :arg1, "desc", :short => "a"
    @p.opt :arg2, "desc", :short => "b"
    @p.opt :arg3, "desc", :short => "c", :type => :ints
    @p.opt :arg4, "desc", :short => "d", :type => :floats

    opts = @p.parse %w(-abc 4 6 9)
    assert_equal true, opts[:arg1]
    assert_equal true, opts[:arg2]
    assert_equal [4, 6, 9], opts[:arg3]

    opts = @p.parse %w(-ac 4 6 9 -bd 3.14 2.41)
    assert_equal true, opts[:arg1]
    assert_equal true, opts[:arg2]
    assert_equal [4, 6, 9], opts[:arg3]
    assert_equal [3.14, 2.41], opts[:arg4]

    assert_raises_errmatch(CommandlineError, /option '-c' needs a parameter/) { opts = @p.parse %w(-abcd 3.14 2.41) }
  end

  def test_long_options_with_multiple_options
    @p.opt :xarg, "desc", :type => String, :multi => true
    opts = @p.parse %w(--xarg=a --xarg=b)
    assert_equal %w(a b), opts[:xarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--xarg a --xarg b)
    assert_equal %w(a b), opts[:xarg]
    assert_equal [], @p.leftovers
  end

  def test_long_options_with_multiple_arguments
    @p.opt :xarg, "desc", :type => :ints
    opts = @p.parse %w(--xarg 3 2 5)
    assert_equal [3, 2, 5], opts[:xarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--xarg=3)
    assert_equal [3], opts[:xarg]
    assert_equal [], @p.leftovers

    @p.opt :yarg, "desc", :type => :floats
    opts = @p.parse %w(--yarg 3.14 2.41 5.66)
    assert_equal [3.14, 2.41, 5.66], opts[:yarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--yarg=3.14)
    assert_equal [3.14], opts[:yarg]
    assert_equal [], @p.leftovers

    @p.opt :zarg, "desc", :type => :strings
    opts = @p.parse %w(--zarg a b c)
    assert_equal %w(a b c), opts[:zarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--zarg=a)
    assert_equal %w(a), opts[:zarg]
    assert_equal [], @p.leftovers
  end

  def test_long_options_with_multiple_options_and_arguments
    @p.opt :xarg, "desc", :type => :ints, :multi => true
    opts = @p.parse %w(--xarg 3 2 5 --xarg 2 1)
    assert_equal [[3, 2, 5], [2, 1]], opts[:xarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--xarg=3 --xarg=2)
    assert_equal [[3], [2]], opts[:xarg]
    assert_equal [], @p.leftovers

    @p.opt :yarg, "desc", :type => :floats, :multi => true
    opts = @p.parse %w(--yarg 3.14 2.72 5 --yarg 2.41 1.41)
    assert_equal [[3.14, 2.72, 5], [2.41, 1.41]], opts[:yarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--yarg=3.14 --yarg=2.41)
    assert_equal [[3.14], [2.41]], opts[:yarg]
    assert_equal [], @p.leftovers

    @p.opt :zarg, "desc", :type => :strings, :multi => true
    opts = @p.parse %w(--zarg a b c --zarg d e)
    assert_equal [%w(a b c), %w(d e)], opts[:zarg]
    assert_equal [], @p.leftovers
    opts = @p.parse %w(--zarg=a --zarg=d)
    assert_equal [%w(a), %w(d)], opts[:zarg]
    assert_equal [], @p.leftovers
  end

  def test_long_options_also_take_equals
    @p.opt :arg, "desc", :long => "arg", :type => String, :default => "hello"
    opts = @p.parse %w()
    assert_equal "hello", opts[:arg]
    opts = @p.parse %w(--arg goat)
    assert_equal "goat", opts[:arg]
    opts = @p.parse %w(--arg=goat)
    assert_equal "goat", opts[:arg]
    ## actually, this next one is valid. empty string for --arg, and goat as a
    ## leftover.
    ## assert_raises(CommandlineError) { opts = @p.parse %w(--arg= goat) }
  end

  def test_auto_generated_long_names_convert_underscores_to_hyphens
    @p.opt :hello_there
    assert_equal "hello-there", @p.specs[:hello_there].long.long
  end

  def test_arguments_passed_through_block
    @goat = 3
    boat = 4
    Parser.new(@goat) do |goat|
      boat = goat
    end
    assert_equal @goat, boat
  end

  ## test-only access reader method so that we dont have to
  ## expose settings in the public API.
  class Optimist::Parser
    def get_settings_for_testing ; return @settings ;end
  end

  def test_two_arguments_passed_through_block
    newp = Parser.new(:abcd => 123, :efgh => "other" ) do |i|
    end
    assert_equal newp.get_settings_for_testing[:abcd], 123
    assert_equal newp.get_settings_for_testing[:efgh], "other"
  end


  def test_version_and_help_override_errors
    @p.opt :asdf, "desc", :type => String
    @p.version "version"
    @p.parse %w(--asdf goat)
    assert_raises_errmatch(CommandlineError, /option '--asdf' needs a parameter/) { @p.parse %w(--asdf) }
    assert_raises(HelpNeeded) { @p.parse %w(--asdf --help) }
    assert_raises(VersionNeeded) { @p.parse %w(--asdf --version) }
  end


  ## courtesy neill zero
  def test_two_required_one_missing_accuses_correctly
    @p.opt "arg1", "desc1", :required => true
    @p.opt "arg2", "desc2", :required => true

    assert_raises_errmatch(CommandlineError, /arg2/) { @p.parse(%w(--arg1)) }
    assert_raises_errmatch(CommandlineError, /arg1/) { @p.parse(%w(--arg2)) }
    @p.parse(%w(--arg1 --arg2))
  end

  def test_stopwords_mixed
    @p.opt "arg1", :default => false
    @p.opt "arg2", :default => false
    @p.stop_on %w(happy sad)

    opts = @p.parse %w(--arg1 happy --arg2)
    assert_equal true, opts["arg1"]
    assert_equal false, opts["arg2"]

    ## restart parsing
    @p.leftovers.shift
    opts = @p.parse @p.leftovers
    assert_equal false, opts["arg1"]
    assert_equal true, opts["arg2"]
  end

  def test_stopwords_no_stopwords
    @p.opt "arg1", :default => false
    @p.opt "arg2", :default => false
    @p.stop_on %w(happy sad)

    opts = @p.parse %w(--arg1 --arg2)
    assert_equal true, opts["arg1"]
    assert_equal true, opts["arg2"]

    ## restart parsing
    @p.leftovers.shift
    opts = @p.parse @p.leftovers
    assert_equal false, opts["arg1"]
    assert_equal false, opts["arg2"]
  end

  def test_stopwords_multiple_stopwords
    @p.opt "arg1", :default => false
    @p.opt "arg2", :default => false
    @p.stop_on %w(happy sad)

    opts = @p.parse %w(happy sad --arg1 --arg2)
    assert_equal false, opts["arg1"]
    assert_equal false, opts["arg2"]

    ## restart parsing
    @p.leftovers.shift
    opts = @p.parse @p.leftovers
    assert_equal false, opts["arg1"]
    assert_equal false, opts["arg2"]

    ## restart parsing again
    @p.leftovers.shift
    opts = @p.parse @p.leftovers
    assert_equal true, opts["arg1"]
    assert_equal true, opts["arg2"]
  end

  def test_stopwords_with_short_args
    @p.opt :global_option, "This is a global option", :short => "-g"
    @p.stop_on %w(sub-command-1 sub-command-2)

    global_opts = @p.parse %w(-g sub-command-1 -c)
    cmd = @p.leftovers.shift

    @q = Parser.new
    @q.opt :cmd_option, "This is an option only for the subcommand", :short => "-c"
    cmd_opts = @q.parse @p.leftovers

    assert_equal true, global_opts[:global_option]
    assert_nil global_opts[:cmd_option]

    assert_equal true, cmd_opts[:cmd_option]
    assert_nil cmd_opts[:global_option]

    assert_equal cmd, "sub-command-1"
    assert_equal @q.leftovers, []
  end

  def test_unknown_subcommand
    @p.opt :global_flag, "Global flag", :short => "-g", :type => :flag
    @p.opt :global_param, "Global parameter", :short => "-p", :default => 5
    @p.stop_on_unknown

    expected_opts = { :global_flag => true, :help => false, :global_param => 5, :global_flag_given => true }
    expected_leftovers = [ "my_subcommand", "-c" ]

    assert_parses_correctly @p, %w(--global-flag my_subcommand -c), \
      expected_opts, expected_leftovers
    assert_parses_correctly @p, %w(-g my_subcommand -c), \
      expected_opts, expected_leftovers

    expected_opts = { :global_flag => false, :help => false, :global_param => 5, :global_param_given => true }
    expected_leftovers = [ "my_subcommand", "-c" ]

    assert_parses_correctly @p, %w(-p 5 my_subcommand -c), \
      expected_opts, expected_leftovers
    assert_parses_correctly @p, %w(--global-param 5 my_subcommand -c), \
      expected_opts, expected_leftovers
  end

  def test_alternate_args
    args = %w(-a -b -c)

    opts = ::Optimist.options(args) do
      opt :alpher, "Ralph Alpher", :short => "-a"
      opt :bethe, "Hans Bethe", :short => "-b"
      opt :gamow, "George Gamow", :short => "-c"
    end

    physicists_with_humor = [:alpher, :bethe, :gamow]
    physicists_with_humor.each do |physicist|
      assert_equal true, opts[physicist]
    end
  end

  def test_date_arg_type
    temp = Date.new
    @p.opt :arg, 'desc', :type => :date
    @p.opt :arg2, 'desc', :type => Date
    @p.opt :arg3, 'desc', :default => temp

    opts = @p.parse []
    assert_equal temp, opts[:arg3]

    opts = @p.parse %w(--arg 5/1/2010)
    assert_kind_of Date, opts[:arg]
    assert_equal Date.new(2010, 5, 1), opts[:arg]

    opts = @p.parse %w(--arg2 5/1/2010)
    assert_kind_of Date, opts[:arg2]
    assert_equal Date.new(2010, 5, 1), opts[:arg2]

    opts = @p.parse %w(--arg3)
    assert_equal temp, opts[:arg3]
  end

  def test_unknown_arg_class_type
    assert_raises ArgumentError do
      @p.opt :arg, 'desc', :type => Hash
    end
  end

  def test_io_arg_type
    @p.opt :arg, "desc", :type => :io
    @p.opt :arg2, "desc", :type => IO
    @p.opt :arg3, "desc", :default => $stdout

    opts = @p.parse []
    assert_equal $stdout, opts[:arg3]

    opts = @p.parse %w(--arg /dev/null)
    assert_kind_of File, opts[:arg]
    assert_equal "/dev/null", opts[:arg].path

    #TODO: move to mocks
    #opts = @p.parse %w(--arg2 http://google.com/)
    #assert_kind_of StringIO, opts[:arg2]

    opts = @p.parse %w(--arg3 stdin)
    assert_equal $stdin, opts[:arg3]

    err_regex = %r/file or url for option 'arg' cannot be opened: No such file or directory/
    assert_raises_errmatch(CommandlineError, err_regex) {
      opts = @p.parse %w(--arg /fdasfasef/fessafef/asdfasdfa/fesasf)
    }
  end

  def test_openstruct_style_access
    @p.opt "arg1", "desc", :type => :int
    @p.opt :arg2, "desc", :type => :int

    opts = @p.parse(%w(--arg1 3 --arg2 4))

    opts.arg1
    opts.arg2
    assert_equal 3, opts.arg1
    assert_equal 4, opts.arg2
  end

  def test_multi_args_autobox_defaults
    @p.opt :arg1, "desc", :default => "hello", :multi => true
    @p.opt :arg2, "desc", :default => ["hello"], :multi => true

    opts = @p.parse []
    assert_equal ["hello"], opts[:arg1]
    assert_equal ["hello"], opts[:arg2]

    opts = @p.parse %w(--arg1 hello)
    assert_equal ["hello"], opts[:arg1]
    assert_equal ["hello"], opts[:arg2]

    opts = @p.parse %w(--arg1 hello --arg1 there)
    assert_equal ["hello", "there"], opts[:arg1]
  end

  def test_ambigious_multi_plus_array_default_resolved_as_specified_by_documentation
    @p.opt :arg1, "desc", :default => ["potato"], :multi => true
    @p.opt :arg2, "desc", :default => ["potato"], :multi => true, :type => :strings
    @p.opt :arg3, "desc", :default => ["potato"]
    @p.opt :arg4, "desc", :default => ["potato", "rhubarb"], :short => :none, :multi => true

    ## arg1 should be multi-occurring but not multi-valued
    opts = @p.parse %w(--arg1 one two)
    assert_equal ["one"], opts[:arg1]
    assert_equal ["two"], @p.leftovers

    opts = @p.parse %w(--arg1 one --arg1 two)
    assert_equal ["one", "two"], opts[:arg1]
    assert_equal [], @p.leftovers

    ## arg2 should be multi-valued and multi-occurring
    opts = @p.parse %w(--arg2 one two)
    assert_equal [["one", "two"]], opts[:arg2]
    assert_equal [], @p.leftovers

    ## arg3 should be multi-valued but not multi-occurring
    opts = @p.parse %w(--arg3 one two)
    assert_equal ["one", "two"], opts[:arg3]
    assert_equal [], @p.leftovers

    ## arg4 should be multi-valued but not multi-occurring
    opts = @p.parse %w()
    assert_equal ["potato", "rhubarb"], opts[:arg4]
  end

  def test_given_keys
    @p.opt :arg1
    @p.opt :arg2

    opts = @p.parse %w(--arg1)
    assert opts[:arg1_given]
    assert !opts[:arg2_given]

    opts = @p.parse %w(--arg2)
    assert !opts[:arg1_given]
    assert opts[:arg2_given]

    opts = @p.parse []
    assert !opts[:arg1_given]
    assert !opts[:arg2_given]

    opts = @p.parse %w(--arg1 --arg2)
    assert opts[:arg1_given]
    assert opts[:arg2_given]
  end

  def test_default_shorts_assigned_only_after_user_shorts
    @p.opt :aab, "aaa" # should be assigned to -b
    @p.opt :ccd, "bbb" # should be assigned to -d
    @p.opt :user1, "user1", :short => 'a'
    @p.opt :user2, "user2", :short => 'c'

    opts = @p.parse %w(-a -b)
    assert opts[:user1]
    assert !opts[:user2]
    assert opts[:aab]
    assert !opts[:ccd]

    opts = @p.parse %w(-c -d)
    assert !opts[:user1]
    assert opts[:user2]
    assert !opts[:aab]
    assert opts[:ccd]
  end

  def test_short_opts_not_implicitly_created
    newp = Parser.new(implicit_short_opts: false)
    newp.opt :user1, "user1"
    newp.opt :bag, "bag", :short => 'b'
    assert_raises_errmatch(CommandlineError, /unknown argument '-u'/) do
      newp.parse %w(-u)
    end
    opts = newp.parse %w(--user1)
    assert opts[:user1]
    opts = newp.parse %w(-b)
    assert opts[:bag]
  end

  def test_short_opts_not_implicit_help_ver
    # When implicit_short_opts is false this implies the short options
    # for the built-in help/version are also not created.
    newp = Parser.new(implicit_short_opts: false)
    newp.opt :abc, "abc"
    newp.version "3.4.5"
    assert_raises_errmatch(CommandlineError, /unknown argument '-h'/) do
      newp.parse %w(-h)
    end
    assert_raises_errmatch(CommandlineError, /unknown argument '-v'/) do
      newp.parse %w(-v)
    end
    assert_raises(HelpNeeded) do
      newp.parse %w(--help)
    end
    assert_raises(VersionNeeded) do
      newp.parse %w(--version)
    end
  end

  def test_inexact_match
    newp = Parser.new(exact_match: false)
    newp.opt :liberation, "liberate something", :type => :int
    newp.opt :evaluate, "evaluate something", :type => :string
    opts = newp.parse %w(--lib 5 --ev bar)
    assert_equal 5, opts[:liberation]
    assert_equal 'bar', opts[:evaluate]
    assert_nil opts[:eval]
  end

  def test_exact_match
    newp = Parser.new()
    newp.opt :liberation, "liberate something", :type => :int
    newp.opt :evaluate, "evaluate something", :type => :string
    assert_raises_errmatch(CommandlineError, /unknown argument '--lib'/) do
      newp.parse %w(--lib 5)
    end
    assert_raises_errmatch(CommandlineError, /unknown argument '--ev'/) do
      newp.parse %w(--ev bar)
    end
  end

  def test_inexact_collision
    newp = Parser.new(exact_match: false)
    newp.opt :bookname, "name of a book", :type => :string
    newp.opt :bookcost, "cost of the book", :type => :string
    opts = newp.parse %w(--bookn hairy_potsworth --bookc 10)
    assert_equal 'hairy_potsworth', opts[:bookname]
    assert_equal '10', opts[:bookcost]
    assert_raises_errmatch(CommandlineError, /ambiguous option '--book' matched keys \(bookname,bookcost\)/) do
      newp.parse %w(--book 5) # ambiguous
    end
    ## partial match causes 'specified multiple times' error
    assert_raises_errmatch(CommandlineError, /specified multiple times/) do
      newp.parse %w(--bookc 17 --bookcost 22)
    end
  end

  def test_inexact_collision_with_exact
    newp = Parser.new(exact_match: false)
    newp.opt :book, "name of a book", :type => :string, :default => "ABC"
    newp.opt :bookcost, "cost of the book", :type => :int, :default => 5
    opts = newp.parse %w(--book warthog --bookc 3)
    assert_equal 'warthog', opts[:book]
    assert_equal 3, opts[:bookcost]
  end

  def test_accepts_arguments_with_spaces
    @p.opt :arg1, "arg", :type => String
    @p.opt :arg2, "arg2", :type => String

    opts = @p.parse ["--arg1", "hello there", "--arg2=hello there"]
    assert_equal "hello there", opts[:arg1]
    assert_equal "hello there", opts[:arg2]
    assert_equal 0, @p.leftovers.size
  end

  def test_multi_args_default_to_empty_array
    @p.opt :arg1, "arg", :multi => true
    opts = @p.parse []
    assert_equal [], opts[:arg1]
  end

  def test_simple_interface_handles_help
    assert_stdout(/Options:/) do
      assert_raises(SystemExit) do
        ::Optimist::options(%w(-h)) do
          opt :potato
        end
      end
    end

    # ensure regular status is returned

    assert_stdout do
      begin
        ::Optimist::options(%w(-h)) do
          opt :potato
        end
      rescue SystemExit => e
        assert_equal 0, e.status
      end
    end
  end

  def test_simple_interface_handles_version
    assert_stdout(/1.2/) do
      assert_raises(SystemExit) do
        ::Optimist::options(%w(-v)) do
          version "1.2"
          opt :potato
        end
      end
    end
  end

  def test_simple_interface_handles_regular_usage
    opts = ::Optimist::options(%w(--potato)) do
      opt :potato
    end
    assert opts[:potato]
  end

  def test_simple_interface_handles_die
    assert_stderr(/Error: argument --potato is invalid/) do
      ::Optimist::options(%w(--potato)) do
        opt :potato
      end
      assert_raises(SystemExit) { ::Optimist::die :potato, "is invalid" }
    end
  end

  def test_simple_interface_handles_die_without_message
    assert_stderr(/Error: potato\./) do
      ::Optimist::options(%w(--potato)) do
        opt :potato
      end
      assert_raises(SystemExit) { ::Optimist::die :potato }
    end
  end

  def test_invalid_option_with_simple_interface
    assert_stderr(/Error: unknown argument \'--potato\'\./) do
      assert_raises(SystemExit) do
        ::Optimist.options(%w(--potato))
      end
    end

    assert_stderr do
      begin
        ::Optimist.options(%w(--potato))
      rescue SystemExit => e
        assert_equal(-1, e.status)
      end
    end
  end

  def test_supports_callback_inline
    assert_raises_errmatch(RuntimeError, "good") do
      @p.opt :cb1 do |vals|
        raise "good"
      end
      @p.parse(%w(--cb1))
    end
  end

  def test_supports_callback_param
    assert_raises_errmatch(RuntimeError, "good") do
      @p.opt :cb1, "with callback", :callback => lambda { |vals| raise "good" }
      @p.parse(%w(--cb1))
    end
  end

  def test_ignore_invalid_options
    @p.opt :arg1, "desc", :type => String
    @p.opt :b, "desc", :type => String
    @p.opt :c, "desc", :type => :flag
    @p.opt :d, "desc", :type => :flag
    @p.ignore_invalid_options = true
    opts = @p.parse %w{unknown -S param --arg1 potato -fb daisy --foo -ecg --bar baz -z}
    assert_equal "potato", opts[:arg1]
    assert_equal "daisy", opts[:b]
    assert opts[:c]
    refute opts[:d]
    assert_equal %w{unknown -S param -f --foo -eg --bar baz -z}, @p.leftovers
  end

  def test_ignore_invalid_options_stop_on_unknown_long
    @p.opt :arg1, "desc", :type => String
    @p.ignore_invalid_options = true
    @p.stop_on_unknown
    opts = @p.parse %w{--unk --arg1 potato}
    refute opts[:arg1]
    assert_equal %w{--unk --arg1 potato}, @p.leftovers
  end

  def test_ignore_invalid_options_stop_on_unknown_short
    @p.opt :arg1, "desc", :type => String
    @p.ignore_invalid_options = true
    @p.stop_on_unknown
    opts = @p.parse %w{-ua potato}
    refute opts[:arg1]
    assert_equal %w{-ua potato}, @p.leftovers
  end

  def test_ignore_invalid_options_stop_on_unknown_partial_end_short
    @p.opt :arg1, "desc", :type => :flag
    @p.ignore_invalid_options = true
    @p.stop_on_unknown
    opts = @p.parse %w{-au potato}
    assert opts[:arg1]
    assert_equal %w{-u potato}, @p.leftovers
  end

  def test_ignore_invalid_options_stop_on_unknown_partial_mid_short
    @p.opt :arg1, "desc", :type => :flag
    @p.ignore_invalid_options = true
    @p.stop_on_unknown
    opts = @p.parse %w{-abu potato}
    assert opts[:arg1]
    assert_equal %w{-bu potato}, @p.leftovers
  end

  # Due to strangeness in how the cloaker works, there were
  # cases where Optimist.parse would work, but Optimist.options
  # did not, depending on arguments given to the function.
  # These serve to validate different args given to Optimist.options
  def test_options_takes_hashy_settings
    passargs_copy = []
    settings_copy = []
    ::Optimist.options(%w(--wig --pig), :fizz=>:buzz, :bear=>:cat) do |*passargs|
      opt :wig
      opt :pig
      passargs_copy = passargs.dup
      settings_copy = @settings
    end
    assert_equal [], passargs_copy
    assert_equal settings_copy[:fizz], :buzz
    assert_equal settings_copy[:bear], :cat
  end

  def test_options_takes_some_other_data
    passargs_copy = []
    settings_copy = []
    ::Optimist.options(%w(--nose --close), 1, 2, 3) do |*passargs|
      opt :nose
      opt :close
      passargs_copy = passargs.dup
      settings_copy = @settings
    end
    assert_equal [1,2,3], passargs_copy
    assert_equal(Optimist::Parser::DEFAULT_SETTINGS, settings_copy)
  end
end

end
