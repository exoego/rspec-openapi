# frozen_string_literal: true

module Minitest::Assertions
  def assert_parses_correctly(parser, commandline, expected_opts,
                              expected_leftovers)
    opts = parser.parse commandline
    assert_equal expected_opts, opts
    assert_equal expected_leftovers, parser.leftovers
  end

  def assert_stderr(str = nil, msg = nil)
    msg = "#{msg}.\n" if msg

    old_stderr, $stderr = $stderr, StringIO.new
    yield
    assert_match str, $stderr.string, msg if str
  ensure
    $stderr = old_stderr
  end

  def assert_stdout(str = nil, msg = nil)
    msg = "#{msg}.\n" if msg

    old_stdout, $stdout = $stdout, StringIO.new
    yield
    assert_match str, $stdout.string, msg if str
  ensure
    $stdout = old_stdout
  end

  # like assert raises, but if it does raise, it checks status
  # NOTE: this does not ensure the exception is raised
  def assert_system_exit *exp
    msg = "#{exp.pop}.\n" if String === exp.last
    status = exp.first

    begin
      yield
    rescue SystemExit => e
      assert_equal status, e.status {
        exception_details(e, "#{msg}#{mu_pp(exp)} exception expected, not")
      } if status
      return true
    end
    flunk "#{msg}#{mu_pp(exp)} SystemExit expected but nothing was raised."
  end

  # wrapper around common assertion checking pattern
  def assert_raises_errmatch(err_klass, err_regexp, &b)
    err = assert_raises(err_klass, &b)
    assert_match(err_regexp, err.message)
  end
end
