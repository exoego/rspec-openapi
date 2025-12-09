# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [3.2.1] - 2025-03-19
### Added
- Added testing of jruby-9.4 ([#172](https://github.com/ManageIQ/optimist/pull/172) - thanks @Fryguy)
- Added testing of Ruby 3.4 ([#173](https://github.com/ManageIQ/optimist/pull/173) - thanks @Fryguy)

### Removed
- Drop testing of Ruby <2.7, jruby-9.3 ([#172](https://github.com/ManageIQ/optimist/pull/172) - thanks @Fryguy)

### Fixed
- Fix issue where negative boolean flags were output incorrectly ([#179](https://github.com/ManageIQ/optimist/pull/179) - thanks @Fryguy)
- Fix issues with frozen strings which fail jruby-head (JRuby 10) ([#180](https://github.com/ManageIQ/optimist/pull/180) - thanks @Fryguy)

## [3.2.0] - 2024-11-11
### Added
- Align the short and long forms into their own columns in the help output ([#145](https://github.com/ManageIQ/optimist/pull/145) - thanks @akhoury6)
- Add support for DidYouMean when long options are spelled incorrectly ([#150](https://github.com/ManageIQ/optimist/pull/150) - thanks @nanobowers)
- Using `permitted:` restricts the allowed values that a end-user inputs to a pre-defined list ([#147](https://github.com/ManageIQ/optimist/pull/147) - thanks @akhoury6)
- Add exact_match to settings, defaulting to inexact matching ([#154](https://github.com/ManageIQ/optimist/pull/154) - thanks @nanobowers)
- Add setting to disable implicit short options ([#155](https://github.com/ManageIQ/optimist/pull/155) - thanks @nanobowers)
- Add alt longname and multiple char support ([#151](https://github.com/ManageIQ/optimist/pull/151) - thanks @nanobowers)
- Permitted regexp/range support ([#158](https://github.com/ManageIQ/optimist/pull/158), [#159](https://github.com/ManageIQ/optimist/pull/159) - thanks @nanobowers)
- Add some examples ([#161](https://github.com/ManageIQ/optimist/pull/161) - thanks @nanobowers)

### Changed
- Enable frozen_string_literal for future-ruby support ([#149](https://github.com/ManageIQ/optimist/pull/149), [#153](https://github.com/ManageIQ/optimist/pull/153)  - thanks @nanobowers)
- Refactor constraints ([#156](https://github.com/ManageIQ/optimist/pull/156) - thanks @nanobowers)
- Fix assert_raises to assert_raises_errmatch ([#160](https://github.com/ManageIQ/optimist/pull/160) - thanks @nanobowers)

## [3.1.0] - 2023-07-24
### Added
- Implement `either` command ([#130](https://github.com/ManageIQ/optimist/pull/130) - thanks @alezummo)

## [3.0.1] - 2020-04-20

- Add a LICENSE.txt file to the released package
- Test fixes (thanks @aried3r, @neontapir, @npras)

## [3.0.0] - 2018-08-24

- The gem has been officially renamed to optimist

## [2.1.3] - 2018-07-05

- Refactor each option type into subclasses of Option.  Define a registry for the registration of each option.  This makes the code more modular and facilitates extension by allowing additional Option subclasses. (thanks @clxy)
- Fixed implementation of ignore_invalid_options. (thanks @metcalf)
- Various warning cleanup for ruby 2.1, 2.3, etc. (thanks @nanobowers)
- Optimist.die can now accept an error code.
- fixed default (thanks @nanobowers)
- Change from ruby license to MIT license in the code.

## [2.1.2] - 2015-03-10

- loosen mime-types requirements (for better ruby 1.8.7 support)
- use io/console gem instead of curses (for better jruby support)
- fix parsing bug when chronic gem is not available
- allow default array to be empty if a type is specified
- better specified license and better spec coverage

## [2.1.1] - 2015-01-03

- Remove curses as a hard dependency. It is optional. This can leverage the gem if it is present.
- Fix ruby -w warnings

## 2.1.0 - 2015-01-02

- Integer parser now supports underscore separator.
- Add Parser#usage and Parser#synopsis commands for creating a standard banner
  message. Using Parser#banner directly will override both of those.
- Add Parser#ignore_invalid_options to prevent erroring on unknown options.
- Allow flags to act as switches if they have defaults set and no value is
  passed on the commandline
- Parser#opt learned to accept a block or a :callback option which it will call
  after parsing the option.
- Add Optimist::educate which displays the help message and dies.
- Reformat help message to be more GNUish.
- Fix command name in help message when script has no extension.
- Fix handling of newlines inside descriptions
- Documentation and other fixes.

## 2.0 - 2012-08-11

- Change flag logic: --no-X will always be false, and --X will always be true,
  regardless of default.
- For flags that default to true, display --no-X instead of --X in the help
  menu. Accept both versions on the commandline.
- Fix a spurious warning
- Update Rakefile to 1.9
- Minor documentation fixes

## 1.16.2 - 2010-04-06

- Bugfix in Optimist::options. Thanks to Brian C. Thomas for pointing it out.

## 1.16.1 - 2010-04-05

- Bugfix in Optimist::die method introduced in last release.

## 1.16 - 2010-04-01

- Add Optimist::with_standard_exception_handling method for easing the use of Parser directly.
- Handle scientific notation in float arguments, thanks to Will Fitzgerald.
- Drop hoe dependency.

## 1.15 - 2009-09-30

- Don't raise an exception when out of short arguments (thanks to Rafael
  Sevilla for pointing out how dumb this behavior was).

## 1.14 - 2009-06-19
- Make :multi arguments default to [], not nil, when not set on the commandline.
- Minor commenting and error message improvements

## 1.13 - 2009-03-16

- Fix parsing of "--longarg=<value with spaces>".

## 1.12 - 2009-01-30

- Fix some unit test failures in the last release. Should be more careful.
- Make default short options only be assigned *after- all user-specified
  short options. Now there's a little less juggling to do when you just
  want to specify a few short options.

## 1.11 - 2009-01-29

- Set <opt>_given keys in the results hash for options that were specified
  on the commandline.

## 1.10.2 - 2008-10-23

- No longer try `stty size` for screen size detection. Just use curses, and
  screen users will have to deal with the screen clearing.

## 1.10.1 - 2008-10-22

- Options hash now responds to method calls as well as standard hash lookup.
- Default values for multi-occurrence parameters now autoboxed.
- The relationship between multi-value, multi-occurrence, and default values
  improved and explained.
- Documentation improvements.

## 1.10 - 2008-10-21

- Added :io type for parameters that point to IO streams (filenames, URIs, etc).
- For screen size detection, first try `stty size` before loading Curses.
- Improved documentation.

## 1.9 - 2008-08-20

- Added 'stop_on_unknown' command to stop parsing on any unknown argument.
  This is useful for handling sub-commands when you don't know the entire
  set of commands up front. (E.g. if the initial arguments can change it.)
- Added a :multi option for parameters, signifying that they can be specified
  multiple times.
- Added :ints, :strings, :doubles, and :floats option types, which can take
  multiple arguments.

## 1.8.2 - 2008-06-25

- Bugfix for #conflicts and #depends error messages

## 1.8.1 - 2008-06-24

- Bugfix for short option autocreation
- More aggressive documentation

## 1.8 - 2008-06-16

- Sub-command support via Parser#stop_on

## 1.7.2 - 2008-01-16

- Ruby 1.9-ify. Apparently this means replacing :'s with ;'s.

## 1.7.1 - 2008-01-07

- Documentation improvements

## 1.7 - 2007-06-17

- Fix incorrect error message for multiple missing required arguments
  (thanks to Neill Zero)

## 1.6 - 2007-04-01

- Don't attempt curses screen-width magic unless running on a terminal.

## 1.5 - 2007-03-31

- --help and --version do the right thing even if the rest of the
  command line is incorrect.
- Added #conflicts and #depends to model dependencies and exclusivity
  between arguments.
- Minor bugfixes.

## 1.4 - 2007-03-26

- Disable short options with :short => :none.
- Minor bugfixes and error message improvements.

## 1.3 - 2007-01-31

- Wrap at (screen width - 1) instead of screen width.
- User can override --help and --version.
- Bugfix in handling of -v and -h.
- More tests to confirm the above.

## 1.2 - 2007-01-31

- Minor documentation tweaks.
- Removed hoe dependency.

## 1.1 - 2007-01-30

- Optimist::options now passes any arguments as block arguments. Since
  instance variables are not properly captured by the block, this
  makes it slightly less noisy to pass them in as local variables.
  (A real-life use for _why's cloaker!)
- Help display now preserves original argument order.
- Optimist::die now also has a single string form in case death is not
  due to a single argument.
- Parser#text now an alias for Parser#banner, and can be called
  multiple times, with the output being placed in the right position
  in the help text.
- Slightly more indicative formatting for parameterized arguments.

## 1.0 - 2007-01-29

- Initial release.

[Unreleased]: https://github.com/ManageIQ/optimist/compare/v3.2.1...HEAD
[3.2.1]: https://github.com/ManageIQ/optimist/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/ManageIQ/optimist/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/ManageIQ/optimist/compare/v3.0.1...v3.1.0
[3.0.1]: https://github.com/ManageIQ/optimist/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/ManageIQ/optimist/compare/v2.1.3...v3.0.0
[2.1.3]: https://github.com/ManageIQ/optimist/compare/v2.1.2...v2.1.3
[2.1.2]: https://github.com/ManageIQ/optimist/compare/v2.1.1...v2.1.2
[2.1.1]: https://github.com/ManageIQ/optimist/compare/v2.1.0...v2.1.1
