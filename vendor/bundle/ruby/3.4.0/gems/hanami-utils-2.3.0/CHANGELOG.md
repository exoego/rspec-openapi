# Hanami::Utils

Ruby core extensions and class utilities for Hanami

## v2.3.0 - 2025-11-12

## v2.3.0.beta2 - 2025-10-17

### Changed

- Drop support for Ruby 3.1

## v2.3.0.beta1 - 2025-10-03

## v2.2.0 - 2024-11-05

## v2.2.0.rc1 - 2024-10-29

## v2.2.0.beta2 - 2024-09-25

## v2.2.0.beta1 - 2024-07-16

### Changed

- Drop support for Ruby 3.0

## v2.1.0 - 2024-02-27

## v2.1.0.rc3 - 2024-02-16

## v2.1.0.rc2 - 2023-11-08

## v2.1.0.beta1 - 2023-06-29

### Changed

- [Tim Riley] Remove `Hanami::Utils::Escape` (which was not public as of 2.0.0) (#410)

## v2.0.3 - 2023-02-01

### Fixed

- [hi-tech-jazz] `Hanami::Utils::Blank.blank?` to check if the current object is non-nil

## v2.0.2 - 2022-12-25

### Added

- [Luca Guidi] Official support for Ruby 3.2

## v2.0.1 - 2022-12-06

### Fixed

- [Tim Riley] Make `Hanami::Utils::Callbacks::Chain` and `Hanami::Utils::Callbacks::Callback` comparable via `#==` based on their contents, rather than their object identity

## v2.0.0 - 2022-11-22

## v2.0.0.rc1 - 2022-11-08

### Fixed

- [Benjamin Klotz] Ensure `Hanami::Utils::String.underscore` to replace `"."` (dot character) into underscore

### Changed

- [Luca Guidi] Removed `Hanami::Logger` in favor of `Dry::Logger`

## v2.0.0.beta1 - 2022-07-20

### Changed

- [Luca Guidi] Removed `Hanami::Utils::BasicObject` (moved to `dry-core` as `Dry::Core::BasicObject`)
- [Luca Guidi] Removed `Hanami::Interactor`

## v2.0.0.alpha6 - 2022-02-10

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.0 and 3.1

### Fixed

- [Rob Jacoby] Allow `Hanami::Logger#initialize` to accept `File::NULL` as `stream:` argument

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.6 and 2.7.

## v2.0.0.alpha3 - 2021-11-09

No changes.

## v2.0.0.alpha2 - 2021-05-04

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.5.
- [Luca Guidi] Transform `Utils::String` from class to module

## v2.0.0.alpha1 - 2019-01-30

### Added

- [Gustavo Caso] Introduce `Hanami::Middleware` namespace
- [Luca Guidi] Introduce `Callbacks::Chain#dup`

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.3, and 2.4.
- [Luca Guidi] Remove `Utils::Duplicable`
- [Luca Guidi] Remove `Utils::Inflector`
- [Luca Guidi] Remove `Utils::String.singularize`, and `.pluralize`
- [Luca Guidi] Remove `Utils::String#singularize`, and `#pluralize`
- [Luca Guidi] Remove instance level interface for `Utils::Hash`
- [Luca Guidi] Transform `Utils::Hash` from class to module
- [Luca Guidi] Remove `Utils.reload!`
- [Gustavo Caso] Remove `Utils::File.rewrite`
- [Vladimir Suvorov] Remove `Utils::Class.load_from_pattern!`

## v1.3.8 - 2021-05-03

### Fixed

- [Hiếu Nguyễn] Ensure `Hanami::Interactor#initialize` to accept keyword arguments while working with Ruby 3

## v1.3.7 - 2021-01-04

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.0
- [Khai Le] Allow `Hanami::Logger` to filter sensitive data for an array of hashes

### Fixed

- [Hiếu Nguyễn] Ensure `Hanami::Logger` to not mutate `Hash` input when filtering sensitive data

## v1.3.6 - 2020-01-07

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.7

### Fixed

- [ippachi] `Utils::Files.append`: don't check breakline if file is empty

## v1.3.5 - 2019-10-25

### Fixed

- [Ivan Kabluchkov] Ensure `Hanami::Logger` filters to not crash when logger stream is a closed tempfile
- [Luca Guidi] Ensure `Utils::Files.append` to append contents properly when existing file doesn't end with a newline

## v1.3.4 - 2019-09-27

### Added

- [Luca Guidi] Let `Utils::BasicObject` to lookup constants at the top-level namespace

## v1.3.3 - 2019-09-13

### Fixed

- [Mauro Morales] Ensure `Utils::Inflector.pluralize` and `.singularize` to work with words that contain an underscore (`_`)

## v1.3.2 - 2019-06-21

### Added

- [Vladislav Yashin & Luca Guidi] Added `Utils::BasicObject#instance_of?`, `#is_a?`, and `#kind_of`

## v1.3.1 - 2019-01-18

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

### Fixed

- [Alfonso Uceda] Fix `Hash` serialization for `Utils::Logger`
- [Jeff Dickey] Add missing `pathname` require in `lib/hanami/utils.rb`

## v1.3.0 - 2018-10-24

## v1.3.0.beta1 - 2018-08-08

### Added

- [Luca Guidi] Official support for JRuby 9.2.0.0
- [graywolf] Add `Utils::Files.inject_line_before_last` and `.inject_line_after_last`

### Fixed

- [graywolf] Don't show `Fixnum` Ruby warning for 2.4+
- [Luca Guidi] Fix pluralization of `"fee"`

### Deprecated

- [Luca Guidi & Marion Schleifer] Deprecate `Utils::String` as Ruby type. Please use `Utils::String` class methods instead of `Utils::String.new("")`.
- [Luca Guidi & Marion Schleifer] Deprecate `Utils::Hash` as Ruby type. Please use `Utils::Hash` class methods instead of `Utils::Hash.new({})`.
- [Luca Guidi & Marion Schleifer] Deprecate `Utils::String.pluralize` and `.singularize`.
- [Semyon Pupkov] Deprecate `Utils::Class.load_from_pattern!`

## v1.2.0 - 2018-04-11

## v1.2.0.rc2 - 2018-04-06

### Added

- [Luca Guidi] Use different colors for each `Hanami::Logger` level

## v1.2.0.rc1 - 2018-03-30

### Added

- [Oana Sipos & Sean Collins & Luca Guidi] Colored logging

### Fixed

- [Luca Guidi] Make `Hanami::Logger` to properly log hash messages

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28

## v1.1.2 - 2018-02-02

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.5

### Fixed

- [Sean Collins & Luca Guidi] Make `Utils::Files.write` idempotent: ensure to truncate the file before to write
- [Sean Collins & Luca Guidi] Don't erase file contents when invoking `Utils::Files.touch`

### Changed

- [Sean Collins & Luca Guidi] Deprecate `Utils::Files.rewrite` in favor of `.write`

## v1.1.1 - 2017-11-22

### Added

- [Luca Guidi] Introduce `Utils::Hash.deep_stringify` to recursively stringify a hash

### Fixed

- [Yuta Tokitake] Ensure `Interactor#call` to accept non-keyword arguments

## v1.1.0 - 2017-10-25

### Added

- [Luca Guidi] Introduce `Utils::Hash.deep_serialize` to recursively serialize input into `::Hash`

## v1.1.0.rc1 - 2017-10-16

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03

### Added

- [Alfonso Uceda] Auto create directory for `Hanami::Logger`

## v1.1.0.beta1 - 2017-08-11

### Added

- [Marion Duprey] Allow `Hanami::Interactor#call` to accept arguments. `#initialize` should be used for Dependency Injection, while `#call` should be used for input
- [Marion Schleifer] Introduce `Utils::Hash.stringify`
- [Marion Schleifer] Introduce `Utils::String.titleize`, `.capitalize`, `.classify`, `.underscore`, `.dasherize`, `.demodulize`, `.namespace`, `.pluralize`, `.singularize`, and `.rsub`
- [Luca Guidi] Introduce `Utils::Files`: a set of utils for file manipulations
- [Luca Guidi] Introduce `Utils::String.transform` a pipelined transformations for strings
- [Marion Duprey & Gabriel Gizotti] Filter sensitive informations for `Hanami::Logger`

## v1.0.4 - 2017-10-02

### Fixed

- [Luca Guidi] Make `Hanami::Utils::BasicObject` to be fully compatible with Ruby's `pp` and to be inspected by Pry.
- [Thiago Kenji Okada] Fix pluralization/singularization for `"release" => "releases"`

## v1.0.3 - 2017-09-06

### Fixed

- [Malina Sulca] Fix pluralization/singularization for `"exercise" => "exercises"`
- [Xavier Barbosa] Fix pluralization/singularization for `"area" => "areas"`

## v1.0.2 - 2017-07-10

### Fixed

- [Anton Davydov] Fix pluralization/singularization for `"phrase" => "phrases"`

## v1.0.1 - 2017-06-23

### Added

- [Luca Guidi] Introduced `Utils::Hash.symbolize` and `.deep_symbolize`
- [Luca Guidi] Introduced `Utils::Hash.deep_dup`

### Fixed

- [choallin] Ensure `Utils::String#classify` to return output identical to the input for already classified strings.
- [Marion Duprey & Jonas Amundsen] Ensure `Utils::Hash#initialize` to accept frozen `Hash` as argument.

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

### Added

- [Luca Guidi] Allow `Hanami::Logger#initialize` to accept arguments to be compliant with Ruby's `Logger`

## v1.0.0.beta3 - 2017-03-17

### Fixed

- [Luca Guidi] Use `$stdout` instead of `STDOUT` as default stream for `Hanami::Logger`

### Changed

- [Luca Guidi] Removed `Utils::Attributes`
- [Luca Guidi] Removed deprecated `Hanami::Interactor::Result#failing?`
- [Luca Guidi] Removed deprecated `Utils::Json.load` and `.dump`

## v1.0.0.beta2 - 2017-03-02

### Changed

- [Anton Davydov] Made `Utils::Blank` private API

## v1.0.0.beta1 - 2017-02-14

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.4
- [alexd16] Introduced `Utils::Hash#deep_symbolize!` for deep symbolization
- [Luca Guidi] Introduced `Hanami::Utils.reload!` as a mechanism to force code reloading in development

### Fixed

- [alexd16 & Alfonso Uceda & Luca Guidi] Don't deeply symbolize `Hanami::Interactor::Result` payload
- [Alfonso Uceda] `Hanami::Interactor::Result`: Don't transform objects that respond to `#to_hash` (like entities)
- [Bhanu Prakash] Use `Utils::Json.generate` instead of the deprecated `.dump` for `Hanami::Logger` JSON formatter
- [Luca Guidi] `Hanami::Logger`: when a `Hash` message is passed, don't nest it under `:message` key, but unwrap at the top level

### Changed

- [alexd16] `Utils::Hash#symbolize!` no longer symbolizes deep structures
- [Luca Guidi & Alfonso Uceda] Improve readability for default logger formatter
- [Luca Guidi] Use ISO-8601 time format for JSON logger formatter

## v0.9.2 - 2016-12-19

### Added

- [Grachev Mikhail] Introduced `Hanami::Interactor::Result#failure?`

### Fixed

- [Paweł Świątkowski] `Utils::Inflector.pluralize` Pluralize -en to -ens instead of -ina

### Changed

- [Grachev Mikhail] Deprecate `Hanami::Interactor::Result#failing?` in favor of `#failure?`

## v0.9.1 - 2016-11-18

### Added

- [Luca Guidi] Introduced `Utils::Json.parse` and `.generate`

### Fixed

- [Luca Guidi] Ensure `Utils::Json` parsing to not eval untrusted input

### Changed

- [Luca Guidi] Deprecated `Utils::Json.load` in favor of `.parse`
- [Luca Guidi] Deprecated `Utils::Json.dump` in favor of `.generate`

## v0.9.0 - 2016-11-15

### Added

– [Luca Guidi] Introduced `Utils.require!` to recursively require Ruby files with an order that is consistent across platforms
– [Luca Guidi] Introduced `Utils::FileList` as cross-platform ordered list of files, alternative to `Dir.glob`

- [Luca Guidi] Make `Utils::BasicObject` pretty printable
- [Grachev Mikhail] Added `Interactor::Result#successful?` and `#failing?`

### Fixed

- [Pascal Betz] Ensure `Utils::Class.load!` to lookup constant only within the given namespace

### Changed

- [Luca Guidi] Make `Utils::Hash` only compatible with objects that respond to `#to_hash`
- [Luca Guidi] Official support for Ruby: MRI 2.3+ and JRuby 9.1.5.0+

## v0.8.0 - 2016-07-22

### Added

- [Andrey Morskov] Introduced `Hanami::Utils::Blank`
- [Anton Davydov] Allow to specify a default log level for `Hanami::Logger`
- [Anton Davydov] Introduced default and JSON formatters for `Hanami::Logger`
- [Erol Fornoles] Allow deep indifferent access for `Hanami::Utils::Attributes`
- [Anton Davydov] Introduced `Hanami::Utils::Json` which is a proxy for `MultiJson` (from `multi_json` gem), or fallback to `JSON` from Ruby standard library.

### Fixed

- [Hiếu Nguyễn] Ensure `Hanami::Utils::String#classify` to return already classified strings as they are. Eg. `"AwesomeProject"` should return `"AwesomeProject"`, not `"Awesomeproject"`.
- [TheSmartnik] Fix English pluralization for words ending with `"rses"`
- [Rogério Ramos] Fix English pluralization for words ending with `"ice"`

### Changed

- [Luca Guidi] Drop support for Ruby 2.0, 2.1 and Rubinius. Official support for JRuby 9.0.5.0+.

## v0.7.1 - 2016-02-05

### Fixed

- [Yuuji Yaginuma] `Hanami::Utils::Escape`: fixed Ruby warning for `String#chars` with a block, which is deprecated. Using `String#each_char` now.
- [Sean Collins] Allow non string objects to be escaped by `Hanami::Utils::Escape`.

## v0.7.0 - 2016-01-22

### Changed

- [Luca Guidi] Renamed the project

## v0.6.1 - 2016-01-19

### Fixed

- [Anton Davydov] Ensure `Lotus::Utils::String#classify` to work properly with dashes (eg. `"app-store" => "App::Store"`)

## v0.6.0 - 2016-01-12

### Added

- [Luca Guidi] Official support for Ruby 2.3
- [Luca Guidi] Custom inflections
- [Luca Guidi] Introduced `Lotus::Utils::Duplicable` as a safe dup logic for Ruby types
- [Luca Guidi] Added `Lotus::Utils::String#rsub` replace rightmost occurrence

### Fixed

- [Luca Guidi] Fix `Lotus::Utils::PathPrefix#join` and `#relative_join` by rejecting arguments that are equal to the separator
- [Karim Kiatlottiavi] Fix `Encoding::UndefinedConversionError` in `Lotus::Utils::Escape.encode`

### Changed

- [Luca Guidi] Deprecate Ruby 2.0 and 2.1
- [Luca Guidi] Removed `Lotus::Utils::Callbacks#add` in favor of `#append`
- [Luca Guidi] Removed pattern support for `Utils::Class.load!` (eg. `Articles(Controller|::Controller)`)

## v0.5.2 - 2015-09-30

### Added

- [Luca Guidi] Added `Lotus::Utils::String#capitalize`
- [Trung Lê] Official support for JRuby 9k+

## v0.5.1 - 2015-07-10

### Fixed

- [Thiago Felippe] Ensure `Lotus::Utils::PathPrefix#join` won't remote duplicate entries (eg `/admin/dashboard/admin`)

## v0.5.0 - 2015-06-23

### Added

- [Luca Guidi] Extracted `Lotus::Logger` from `hanamirb`

### Changed

- [Luca Guidi] `Lotus::Interactor::Result` contains only objects explicitly exposed via `Lotus::Interactor.expose`.

## v0.4.3 - 2015-05-22

### Added

- [François Beausoleil] Improved `Lotus::Utils::Kernel` messages for `TypeError`.

## v0.4.2 - 2015-05-15

### Fixed

- [Luca Guidi] Ensure `Lotus::Utils::Attributes#to_h` to return `::Hash`

## v0.4.1 - 2015-05-15

### Added

- [Luca Guidi & Alfonso Uceda Pompa] Introduced `Lotus::Utils::Inflector`, `Lotus::Utils::String#pluralize` and `#singularize`

### Fixed

- [Luca Guidi] Ensure `Lotus::Utils::Attributes#to_h` to safely return nested `::Hash` instances for complex data structures.
- [Luca Guidi] Let `Lotus::Interactor#error` to return a falsey value for control flow. (eg. `check_permissions or error "You can't access"`)

## v0.4.0 - 2015-03-23

### Added

- [Luca Guidi] Introduced `Lotus::Utils::Escape`. It implements OWASP/ESAPI suggestions for HTML, HTML attribute and URL escape utilities.
- [Luca Guidi] Introduced `Lotus::Utils::String#dasherize`
- [Luca Guidi] Introduced `Lotus::Utils::String#titleize`

## v0.3.5 - 2015-03-12

### Added

- [Luca Guidi] Introduced `Lotus::Interactor`
- [Luca Guidi] Introduced `Lotus::Utils::BasicObject`

## v0.3.4 - 2015-01-30

### Added

- [Alfonso Uceda Pompa] Aliased `Lotus::Utils::Attributes#get` with `#[]`
- [Simone Carletti] Introduced `Lotus::Utils::Callbacks::Chain#prepend` and `#append`

### Deprecated

- [Luca Guidi] Deprecated `Lotus::Utils::Callbacks::Chain#add` in favor of `#append`

## v0.3.3 - 2015-01-08

### Fixed

- [Luca Guidi] Ensure to return the right offending object if a missing method is called with Utils::String and Hash (eg. `Utils::Hash.new(a: 1).all? {|_, v| v.foo }` blame `v` instead of `Hash`)
- [Luca Guidi] Raise an error if try to coerce non numeric strings into Integer, Float & BigDecimal (eg. `Utils::Kernel.Integer("hello") # => raise TypeError`)

## v0.3.2 - 2014-12-23

### Added

- [Luca Guidi] Official support for Ruby 2.2
- [Luca Guidi] Introduced `Utils::Attributes`
- [Luca Guidi] Added `Utils::Hash#stringify!`

## v0.3.1 - 2014-11-23

### Added

- [Luca Guidi] Allow `Utils::Class.load!` to accept any object that implements `#to_s`
- [Trung Lê] Allow `Utils::Class.load!` to accept a class
- [Luca Guidi] Introduced `Utils::Class.load_from_pattern!`
- [Luca Guidi] Introduced `Utils.jruby?` and `Utils.rubinius?`
- [Luca Guidi] Introduced `Utils::Deprecation`
- [Luca Guidi] Official support for Rubinius 2.3+
- [Luca Guidi] Official support for JRuby 1.7+ (with 2.0 mode)
- [Janko Marohnić] Implemented `Utils::PathPrefix` relativness and absolutness
- [Luca Guidi] Made `Utils::PathPrefix` `#join` and `#relative_join` to return a new instance of that class
- [Luca Guidi] Implemented `Utils::Hash#deep_dup`
- [Luca Guidi] Made `Utils::PathPrefix#join` to accept multiple argument

### Fixed

- [Luca Guidi] Made `Utils::PathPrefix#join` remove trailing occurrences for `@separator` from the output
- [Luca Guidi] Made `Utils::PathPrefix#relative_join` to correctly replace all the instances of `@separator` from the output

### Deprecated

- [Luca Guidi] Deprecated `Utils::Class.load!` with a pattern like `Articles(Controller|::Controller)`, use `Utils::Class.load_from_pattern!` instead

## v0.3.0 - 2014-10-23

### Added

- [Celso Fernandes] Add BigDecimal coercion to Lotus::Utils::Kernel
- [Luca Guidi] Define `Boolean` constant, if missing
- [Luca Guidi] Use composition over inheritance for `Lotus::Utils::PathPrefix`
- [Luca Guidi] Use composition over inheritance for `Lotus::Utils::Hash`
- [Luca Guidi] Use composition over inheritance for `Lotus::Utils::String`

### Fixed

- [Luca Guidi] Improved error message for `Utils::Class.load!`
- [Tom Kadwill] Improved error `NameError` message by passing in the whole constant name to `Utils::Class.load!`
- [Luca Guidi] `Utils::Hash#to_h` return instances of `::Hash` in case of nested symbolized data structure
- [Luca Guidi] Raise `TypeError` if `nil` is passed to `PathPrefix#relative_join`
- [Peter Suschlik] Define `Lotus::Utils::Hash#respond_to_missing?`
- [Peter Suschlik] Define `Lotus::Utils::String#responds_to_missing?`
- [Luca Guidi] Ensure `Utils::Hash#inspect` output to be the same of `::Hash#inspect`

## v0.2.0 - 2014-06-23

### Added

- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Symbol`
- [Luca Guidi] Made `Kernel.Pathname` to raise an error when `nil` is passed as argument
- [Luca Guidi] Implemented `Lotus::Utils::LoadPaths#freeze` in order to prevent modification after the object has been frozen
- [Luca Guidi] Implemented Lotus::Utils::LoadPaths#push, also aliased as #<<
- [Luca Guidi] Use composition over inheritance for `Lotus::Utils::LoadPaths`
- [Luca Guidi] Introduced `Lotus::Utils::LoadPaths`
- [Luca Guidi] Introduced `Lotus::Utils::String#namespace`, in order to return the top level Ruby namespace for the given string
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Pathname`

### Fixed

- [Luca Guidi] Implemented `Lotus::Utils::LoadPaths#initialize_copy` in order to safely `#dup` and `#clone`

### Changed

- [Luca Guidi] Implemented `Lotus::Utils::Callbacks::Chain#freeze` in order to prevent modification after the object has been frozen
- [Luca Guidi] All the `Utils::Kernel` methods will raise `TypeError` in case of failed coercion.
- [Luca Guidi] Made `Kernel.Time` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.DateTime` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Date` to raise an error when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Boolean` to return false when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.String` to return an empty string when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Float` to return `0.0` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Integer` to return `0` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Hash` to return an empty `Hash` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Set` to return an empty `Set` when `nil` is passed as argument
- [Luca Guidi] Made `Kernel.Array` to return an empty `Array` when `nil` is passed as argument
- [Luca Guidi] Use composition over inheritance for `Lotus::Utils::Callbacks::Chain`

## v0.1.1 - 2014-04-23

### Added

- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Time`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.DateTime`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Date`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Float`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Boolean`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Hash`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Set`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.String`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Integer`
- [Luca Guidi] Implemented `Lotus::Utils::Kernel.Array`

### Fixed

- [Christopher Keele] Add missing stdlib `Set` require to `Utils::ClassAttribute`

## v0.1.0 - 2014-01-23

### Added

- [Luca Guidi] Introduced `Lotus::Utils::String#demodulize`
- [Luca Guidi] Introduced `Lotus::Utils::IO.silence_warnings`
- [Luca Guidi] Introduced class loading mechanism from a string: `Utils::Class.load!`
- [Luca Guidi] Introduced callbacks support for classes
- [Luca Guidi] Introduced inheritable class level attributes
- [Luca Guidi] Introduced `Utils::Hash`
- [Luca Guidi] Introduced `Utils::String`
- [Luca Guidi] Introduced `Utils::PathPrefix`
- [Luca Guidi] Official support for MRI 2.0+
