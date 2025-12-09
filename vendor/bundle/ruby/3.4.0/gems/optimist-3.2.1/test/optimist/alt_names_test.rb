require_relative '../test_helper'

module Optimist

  class AlternateNamesTest < ::Minitest::Test

    def setup
      @p = Parser.new
    end

    def get_help_string
      assert_raises(Optimist::HelpNeeded) do
        @p.parse(%w(--help))
      end
      sio = StringIO.new
      @p.educate sio
      sio.string
    end

    def test_altshort
      @p.opt :catarg, "desc", :short => ["c", "-C"]
       opts = @p.parse %w(-c)
       assert_equal true, opts[:catarg]
       opts = @p.parse %w(-C)
       assert_equal true, opts[:catarg]
       err_regex = /option '-C' specified multiple times/
       assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-c -C) }
       assert_raises_errmatch(CommandlineError, err_regex) { @p.parse %w(-cC) }
    end

    def test_altshort_invalid_none
      err_regex = /Cannot use :none with any other values in short option:/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :something, "some opt", :short => [:s, :none]
      }
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :something, "some opt", :short => [:none, :s]
      }
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :zumthing, "some opt", :short => [:none, :none]
      }
    end

    def test_altshort_with_multi
      @p.opt :flag, "desc", :short => ["-c", "C", :x], :multi => true
      @p.opt :num, "desc", :short => ["-n", "N"], :multi => true, type: Integer
      @p.parse %w(-c)
      @p.parse %w(-C -c -x)
      @p.parse %w(-c -C)
      @p.parse %w(-c -C -c -C)
      opts = @p.parse %w(-ccCx)
      assert_equal true, opts[:flag]
      @p.parse %w(-c)
      @p.parse %w(-N 1 -n 3)
      @p.parse %w(-n 2 -N 4)
      opts = @p.parse %w(-n 4 -N 3 -n 2 -N 1)
      assert_equal [4, 3, 2, 1], opts[:num]
    end

    def test_altlong
      @p.opt "goodarg0", "desc", :alt => "zero"
      @p.opt "goodarg1", "desc", :long => "newone", :alt => "one"
      @p.opt "goodarg2", "desc", :alt => "--two"
      @p.opt "goodarg3", "desc", :alt => ["three", "--four", :five]

      [%w[--goodarg0], %w[--zero]].each do |a|
        opts = @p.parse(a)
        assert opts.goodarg0
      end

      [%w[--newone], %w[-n], %w[--one]].each  do |a|
        opts = @p.parse(a)
        assert opts.goodarg1
      end

      [%w[--two]].each  do |a|
        opts = @p.parse(a)
        assert opts.goodarg2
      end

      [%w[--three], %w[--four], %w[--five]].each  do |a|
        opts = @p.parse(a)
        assert opts.goodarg3
      end

      [%w[--goodarg1], %w[--missing], %w[-a]].each do |a|
        assert_raises_errmatch(Optimist::CommandlineError, /unknown argument/) { @p.parse(a) }
      end

      ["", '--', '-bad', '---threedash'].each do |altitem|
        assert_raises_errmatch(ArgumentError, /invalid long option name/) { @p.opt "badarg", "desc", :alt => altitem }
      end
    end

    def test_altshort_help
      @p.opt :cat, 'cat', short: ['c','C','a','T']
      outstring = get_help_string
      # expect mutliple short-opts to be in the help
      assert_match(/-c, -C, -a, -T, --cat/, outstring)
    end


    def test_altlong_help
      @p.opt :cat, 'a cat', alt: :feline
      @p.opt :dog, 'a dog', alt: ['Pooch', :canine]
      @p.opt :fruit, 'a fruit', long: :fig, alt: ['peach', :pear, "--apple"], short: :none
      @p.opt :veg, "gemuse", long: :gemuse, alt: [:groente]
      outstring = get_help_string

      assert_match(/^\s*-c, --cat, --feline/, outstring)
      assert_match(/^\s*-d, --dog, --Pooch, --canine/, outstring)

      # expect long-opt to shadow the actual name
      assert_match(/^\s*--fig, --peach, --pear, --apple/, outstring)
      assert_match(/^\s*-g, --gemuse, --groente/, outstring)

    end

    def test_alt_duplicates
      # alt duplicates named option
      err_regex = /long option name "cat" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :cat, 'desc', :alt => :cat
      }
      # alt duplicates :long
      err_regex = /long option name "feline" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :cat, 'desc', :long => :feline, :alt => [:feline]
      }
      # alt duplicates itself
      err_regex = /long option name "aaa" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :abc, 'desc', :alt => [:aaa, :aaa]
      }
    end

    def test_altlong_collisions
      @p.opt :fat, 'desc'
      @p.opt :raton, 'desc', :long => :rat
      @p.opt :bat, 'desc', :alt => [:baton, :twirl]

      # :alt collision with named option
      err_regex = /long option name "fat" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :cat, 'desc', :alt => :fat
      }

      # :alt collision with :long option
      err_regex = /long option name "cat" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :cat, 'desc', :alt => :rat
      }

      # :named option collision with existing :alt option
      err_regex = /long option name "baton" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :baton, 'desc'
      }

      # :long option collision with existing :alt option
      err_regex = /long option name "twirl" is already taken; please specify a \(different\) :long\/:alt/
      assert_raises_errmatch(ArgumentError, err_regex) {
        @p.opt :whirl, 'desc', :long => 'twirl'
      }

    end
  end
end
