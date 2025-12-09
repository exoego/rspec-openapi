require_relative 'test_helper'

class OptimistTest < Minitest::Test
  def setup
    Optimist.send(:instance_variable_set, "@last_parser", nil)
  end

  def parser(&block)
    Optimist::Parser.new(&block)
  end

  def test_options
    opts = Optimist.options %w(-f) do
      opt :f
    end

    assert_equal true, opts[:f]
  end

  def test_options_die_default
    assert_stderr(/Error: unknown argument.*Try --help/m) do
      assert_system_exit(-1) do
        Optimist.options %w(-f) do
          opt :x
        end
      end
    end
  end

  def test_options_die_educate_on_error
    assert_stderr(/Error: unknown argument.*Options/m) do
      assert_system_exit(-1) do
        Optimist.options %w(-f) do
          opt :x
          educate_on_error
        end
      end
    end
  end

  def test_die_without_options_ever_run
    err_regex = /Optimist::die can only be called after Optimist::options/
    assert_raises_errmatch(ArgumentError, err_regex) { Optimist.die 'hello' }
  end

  def test_die
    assert_stderr(/Error: issue with parsing/) do
      assert_system_exit(-1) do
        Optimist.options []
        Optimist.die "issue with parsing"
      end
    end
  end

  def test_die_custom_error_code
    assert_stderr(/Error: issue with parsing/) do
      assert_system_exit(5) do
        Optimist.options []
        Optimist.die "issue with parsing", nil, 5
      end
    end
  end

  def test_die_custom_error_code_two_args
    assert_stderr(/Error: issue with parsing/) do
      assert_system_exit(5) do
        Optimist.options []
        Optimist.die "issue with parsing", 5
      end
    end
  end

  def test_educate_without_options_ever_run
    err_regex = /Optimist::educate can only be called after Optimist::options/
    assert_raises_errmatch(ArgumentError, err_regex) { Optimist.educate }
  end

  def test_educate
    assert_stdout(/Show this message/) do
      assert_system_exit(0) do
        Optimist.options []
        Optimist.educate
      end
    end
  end

  def test_with_standard_exception_options
    p = parser do
      opt :f
    end

    opts = Optimist::with_standard_exception_handling p do
      p.parse %w(-f)
    end

    assert_equal true, opts[:f]
  end

  def test_with_standard_exception_version_exception
    p = parser do
      version "5.5"
    end

    assert_stdout(/5\.5/) do
      assert_system_exit(0) do
        Optimist::with_standard_exception_handling p do
          raise Optimist::VersionNeeded
        end
      end
    end
  end

  def test_with_standard_exception_version_flag
    p = parser do
      version "5.5"
    end

    assert_stdout(/5\.5/) do
      assert_system_exit(0) do
        Optimist::with_standard_exception_handling p do
          p.parse %w(-v)
        end
      end
    end
  end

  def test_with_standard_exception_die_exception
    assert_stderr(/Error: cl error/) do
      assert_system_exit(-1) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          raise ::Optimist::CommandlineError.new('cl error')
        end
      end
    end
  end

  def test_with_standard_exception_die_exception_custom_error
    assert_stderr(/Error: cl error/) do
      assert_system_exit(5) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          raise ::Optimist::CommandlineError.new('cl error', 5)
        end
      end
    end
  end

  def test_with_standard_exception_die
    assert_stderr(/Error: cl error/) do
      assert_system_exit(-1) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          p.die 'cl error'
        end
      end
    end
  end

  def test_with_standard_exception_die_custom_error
    assert_stderr(/Error: cl error/) do
      assert_system_exit(3) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          p.die 'cl error', nil, 3
        end
      end
    end
  end

  def test_with_standard_exception_help_needed
    assert_stdout(/Options/) do
      assert_system_exit(0) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          raise Optimist::HelpNeeded
        end
      end
    end
  end

  def test_with_standard_exception_help_needed_flag
    assert_stdout(/Options/) do
      assert_system_exit(0) do
        p = parser
        Optimist.with_standard_exception_handling(p) do
          p.parse(%w(-h))
        end
      end
    end
  end
end
