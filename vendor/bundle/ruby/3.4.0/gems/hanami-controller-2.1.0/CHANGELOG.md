# Hanami::Controller

Complete, fast and testable actions for Rack

## v2.1.0 - 2024-02-27

## v2.1.0.rc3 - 2024-02-16

## v2.1.0.rc2 - 2023-11-08

## v2.1.0.rc1 - 2023-11-01

### Fixed

- [Luca Guidi] Ensure Rack compatibility of `Hanami::Action::Response#send_file` (#431)

## v2.1.0.beta2 - 2023-10-04

### Fixed

- [Luca Guidi] `Hanami::Action::Config#root`: don't check realpath existence to simplify the boot process of Hanami (#429)

## v2.1.0.beta1 - 2023-06-29

### Added

- [Tim Riley] Add `Request#session_enabled?` and `Response#session_enabled?` (#423)

## v2.0.2 - 2023-02-01

### Added

- [Adam Lassek] Params Pattern Matching
- [Adam Lassek, Luca Guidi] Allow to `halt` using a `Symbol`: `halt :unauthorized`
- [Adam Lassek, Luca Guidi] Introduce `Hanami::Action::Response#status=` to accept an `Integer` or a `Symbol`

### Fixed

- [Pat Allan] Ensure action accepting the request with a custom MIME Type
- [Luca Guidi] Halting with an unknown HTTP code will raise a `Hanami::Action::UnknownHttpStatusError`
- [Luca Guidi] Fix error message for missing format (MIME Type)

## v2.0.1 - 2022-12-25

### Added

- [Luca Guidi] Official support for Ruby 3.2

## v2.0.0 - 2022-11-22

### Added

- [Tim Riley] Use Zeitwerk to autoload the gem
- [Tim Riley] Introduce `Hanami::Action::Config#formats`. Use `config.actions.formats.add(:json)`. Custom formats can use `config.actions.formats.add(:graphql, ["application/graphql"])`

### Changed

- [Tim Riley] Changed `Hanami::Action::Config#format` semantic: it's no longer used to add custom MIME Types, but as a macro to setup the wanted format for action(s)
- [Tim Riley] Removed `Hanami::Action::Config#default_request_format` and `#default_response_format`, use `#format` for both
- [Tim Riley] Removed `Hanami::Action::Config#accept`, use `#format`

## v2.0.0.rc1 - 2022-11-08

### Changed

- [Tim Riley] Simplify assignment of response format: `response.format = :json` (was `response.format = format(:json)`)

## v2.0.0.beta4 - 2022-10-24

### Added

- [Tim Riley] Add `Response#flash`, and delgate to request object for both `Response#session` and `Response#flash`, ensuring the same objects are used when accessed via either request or response (#399)

### Fixed

- [Benjamin Klotz] When a params validation schema is provided (in a `params do` block), only return the validated params from `request.params` (#375)
- [Sean Collins] Handle dry-schema's messages hash now being frozen by default (#391)

### Changed

- [Tim Riley] When `Action.accept` is declared (or `Action::Config.accepted_formats` configured), return a 406 error if an `Accept` request header is present but is not acceptable. In the absence of an `Accept` header, return a 415 error if a `Content-Type` header is present but not acceptable. If neither header is provided, accept the request. (#396)
- [Tim Riley] Add `Action.handle_exception` class method as a shortcut for `Hanami::Action::Config#handle_exception` (#394)
- [Tim Riley] Significantly reduce memory usage by leveraging recent dry-configurable changes, and relocating `accepted_formats`, `before_callbacks`, `after_callbacks` inheritable attributes to `config` (#392)
- [Tim Riley] Make params validation schemas (defined in `params do` block) inheritable to subclasses (#394)
- [Benhamin Klotz, Tim Riley] Raise `Hanami::Action::MissingSessionError` with a friendly message if `Request#session`, `Request#flash`, `Response#session` or `Response#flash` are called for an action that does not already include `Hanami::Action:Session` mixin (#379 via #395)

## v2.0.0.beta1 - 2022-07-20

### Fixed

- [Benjamin Klotz] Using `Hanami::Action.params` without having `hanami-validations` installed now returns a user-friendly error
- [Narinda Reeders] Ensure HEAD responses to send empty body, but preserve headers
- [Narinda Reeders] Ensure HEAD redirect responses to return redirect headers
- [Andrew Croome] Do not automatically render halted requests

## v2.0.0.alpha8 - 2022-02-19

### Changed

- [Tim Riley] Removed automatic integration of `Hanami::Action` subclasses with their surrounding Hanami application. Action base classes within Hanami apps should inherit from `Hanami::Application::Action` instead.

## v2.0.0.alpha6 - 2022-02-10

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.1

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.6, and 2.7.
- [Sean Collins] Align with Rack list of HTTP supported status. Added: `103`, `306`, `421`, `425`, `451`, and `509`. Removed: `418`, `420`, `444`, `449`, `450`, `451`, `499`, `598`, `599`.

## v2.0.0.alpha5 - 2022-01-12

### Added

- [Philip Arndt] Added "rss" ("application/rss+xml") to list of supported MIME types

## v2.0.0.alpha4 - 2021-12-07

### Added

- [Luca Guidi] Manage Content Security Policy (CSP) defaults and new API via `Hanami::Action::ApplicationConfiguration#content_security_policy`
- [Tim Riley & Marc Busqué] Provide access to routes inside all application actions via `Hanami::Action::ApplicationAction#routes`

## v2.0.0.alpha3 - 2021-11-09

### Added

- [Luca Guidi] Automatically include session behavior in `Hanami::Action` when sessions are enabled via Hanami application config
- [Sean Collins] Pass exposures from action to view

### Changed

- [Tim Riley] (Internal) Updated settings to use updated `setting` API in dry-configurable 0.13.0
- [Sean Collins] Move automatic view rendering from `handle` to `finish`

## v2.0.0.alpha2 - 2021-05-04

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.0
- [Tim Riley] Introduced `Hanami::Action::ApplicationAction`
- [Tim Riley] Introduced `Hanami::Action::Configuration`
- [Tim Riley] Introduced `Hanami::Action::ApplicationConfiguration`
- [Tim Riley] Auto-inject a paired view into any `Hanami::Action::ApplicationAction` instance
- [Tim Riley] Auto-render `Hanami::Action::ApplicationAction` subclasses that don't implement `#handle`
- [Tim Riley] Enable CSRF protection automatically when HTTP sessions are enabled

### Fixed

- [Luca Guidi] Ensure `Hanami::Action::Response#renderable?` to return `false` when body is set
- [Andrew Croome] Ensure `Hanami::Action.accept` to use Rack `CONTENT_TYPE` for the _before callback_ check

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.5.
- [Tim Riley] Removed `Hanami::Action.handle_exception` in favor of `Hanami::Action.config.handle_exception`
- [Tim Riley] Rewritten `Hanami::Action::Flash`, based on Roda's `FlashHash`

## v2.0.0.alpha1 - 2019-01-30

### Added

- [Luca Guidi] `Hanami::Action::Request#session` to access the HTTP session as it was originally sent
- [Luca Guidi] `Hanami::Action::Request#cookies` to access the HTTP cookies as they were originally sent
- [Luca Guidi & Tim Riley] Allow to build a deep inheritance chain for actions

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.3, and 2.4.
- [Luca Guidi] `Hanami::Action` is a superclass
- [Luca Guidi] `Hanami::Action#initialize` requires a `configuration:` keyword argument
- [Luca Guidi] `Hanami::Action#initialize` returns a frozen action instance
- [Tim Riley] `Hanami::Action` subclasses must implement `#handle` instead of `#call`
- [Luca Guidi] `Hanami::Action#handle` accepts `Hanami::Action::Request` and `Hanami::Action::Response`
- [Luca Guidi] `Hanami::Action#handle` returns `Hanami::Action::Response`
- [Luca Guidi] Removed `Hanami::Controller.configure`, `.configuration`, `.duplicate`, and `.load!`
- [Luca Guidi] Removed `Hanami::Action.use` to mount Rack middleware at the action level
- [Luca Guidi] `Hanami::Controller::Configuration` changed syntax from DSL style to setters (eg. `Hanami::Controller::Configuration.new { |c| c.default_request_format = :html }`)
- [Luca Guidi] `Hanami::Controller::Configuration#initialize` returns a frozen configuration instance
- [Luca Guidi] Removed `Hanami::Controller::Configuration#prepare`
- [Luca Guidi] Removed `Hanami::Action.configuration`
- [Luca Guidi] Removed `Hanami::Action.configuration.handle_exceptions`
- [Luca Guidi] Removed `Hanami::Action.configuration.default_request_format` in favor of `#default_request_format`
- [Luca Guidi] Removed `Hanami::Action.configuration.default_charset` in favor of `#default_charset`
- [Luca Guidi] Removed `Hanami::Action.configuration.format` to register a MIME Type for a single action. Please use the configuration.
- [Luca Guidi] Removed `Hanami::Action.expose` in favor of `Hanami::Action::Response#[]=` and `#[]`
- [Luca Guidi] Removed `Hanami::Action#status=` in favor of `Hanami::Action::Response#status=`
- [Luca Guidi] Removed `Hanami::Action#body=` in favor of `Hanami::Action::Response#body=`
- [Luca Guidi] Removed `Hanami::Action#headers` in favor of `Hanami::Action::Response#headers`
- [Luca Guidi] Removed `Hanami::Action#accept?` in favor of `Hanami::Action::Request#accept?`
- [Luca Guidi] Removed `Hanami::Action#format` in favor of `Hanami::Action::Response#format`
- [Luca Guidi] Introduced `Hanami::Action#format` as factory to assign response format: `res.format = format(:json)` or `res.format = format("application/json")`
- [Luca Guidi] Removed `Hanami::Action#format=` in favor of `Hanami::Action::Response#format=`
- [Gustavo Caso] `Hanami::Action.accept` now looks at request `Content-Type` header to accept/deny a request
- [Luca Guidi] Removed `Hanami::Action#request_id` in favor of `Hanami::Action::Request#id`
- [Gustavo Caso] Removed `Hanami::Action#parsed_request_body` in favor of `Hanami::Action::Request#parsed_body`
- [Luca Guidi] Removed `Hanami::Action#head?` in favor of `Hanami::Action::Request#head?`
- [Luca Guidi] Removed `Hanami::Action#status` in favor of `Hanami::Action::Response#status=` and `#body=`
- [Luca Guidi] Removed `Hanami::Action#session` in favor of `Hanami::Action::Response#session`
- [Luca Guidi] Removed `Hanami::Action#cookies` in favor of `Hanami::Action::Response#cookies`
- [Luca Guidi] Removed `Hanami::Action#flash` in favor of `Hanami::Action::Response#flash`
- [Luca Guidi] Removed `Hanami::Action#redirect_to` in favor of `Hanami::Action::Response#redirect_to`
- [Luca Guidi] Removed `Hanami::Action#cache_control`, `#expires`, and `#fresh` in favor of `Hanami::Action::Response#cache_control`, `#expires`, and `#fresh`, respectively
- [Luca Guidi] Removed `Hanami::Action#send_file` and `#unsafe_send_file` in favor of `Hanami::Action::Response#send_file` and `#unsafe_send_file`, respectively
- [Luca Guidi] Removed `Hanami::Action#errors`
- [Gustavo Caso] Removed body cleanup for `HEAD` requests
- [Luca Guidi] `Hanami::Action` callback hooks now accept `Hanami::Action::Request` and `Hanami::Action::Response` arguments
- [Luca Guidi] When an exception is raised, it won't be caught, unless it's handled
- [Luca Guidi] `Hanami::Action` exception handlers now accept `Hanami::Action::Request`, `Hanami::Action::Response`, and exception arguments

## v1.3.3 - 2020-01-14

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.7
- [Luca Guidi] Support `rack` 2.1
- [Luca Guidi] Support for both `hanami-validations` 1 and 2

## v1.3.2 - 2019-06-28

### Fixed

- [Ian Ker-Seymer] Ensure `Etag` to work when `If-Modified-Since` is sent from browser and upstream proxy sets `Last-Modified` automatically.

## v1.3.1 - 2019-01-18

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

## v1.3.0 - 2018-10-24

### Added

- [Gustavo Caso] Swappable JSON backed for `Hanami::Action::Flash` based on `Hanami::Utils::Json`

## v1.3.0.beta1 - 2018-08-08

### Added

- [Luca Guidi] Official support for JRuby 9.2.0.0

### Fixed

- [Yuji Ueki] Ensure that if `If-None-Match` or `If-Modified-Since` response HTTP headers are missing, `Etag` or `Last-Modified` headers will be in response HTTP headers.
- [Gustavo Caso] Don't show flash message for the request after a HTTP redirect.
- [Gustavo Caso] Ensure `Hanami::Action::Flash#each`, `#map`, and `#empty?` to not reference stale flash data.

### Deprecated

- [Gustavo Caso] Deprecate `Hanami::Action#parsed_request_body`

## v1.2.0 - 2018-04-11

## v1.2.0.rc2 - 2018-04-06

### Added

- [Gustavo Caso] Introduce `Hanami::Action::Flash#each` and `#map`

## v1.2.0.rc1 - 2018-03-30

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.5
- [Sergey Fedorov] Introduce `Hanami::Action.content_type` to accept/reject requests according to their `Content-Type` header.

### Fixed

- [wheresmyjetpack] Raise meaningful exception when trying to access `session` or `flash` and `Hanami::Action::Session` wasn't included.

## v1.1.1 - 2017-11-22

### Fixed

- [Luca Guidi] Ensure `Hanami::Action#send_file` and `#unsafe_send_file` to run `after` action callbacks
- [Luca Guidi] Ensure Rack env to have the `REQUEST_METHOD` key set to `GET` during actions unit tests

## v1.1.0 - 2017-10-25

### Added

- [Luca Guidi] Introduce `Hanami::Action::CookieJar#each` to iterate through action's `cookies`

## v1.1.0.rc1 - 2017-10-16

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03

### Added

- [Luca Guidi] Introduce `Hanami::Action::Params::Errors#add` to add errors not generated by params validations

## v1.1.0.beta1 - 2017-08-11

## v1.0.1 - 2017-07-10

### Fixed

- [Marcello Rocha] Ensure validation params to be symbolized in all the environments
- [Marcello Rocha] Fix regression (`1.0.0`) about MIME type priority, during the evaluation of a weighted `Accept` HTTP header

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

## v1.0.0.beta3 - 2017-03-17

### Changed

- [Luca Guidi] `Action#flash` is now public API

## v1.0.0.beta2 - 2017-03-02

### Added

- [Marcello Rocha] Add `Action#unsafe_send_file` to send files outside of the public directory of a project

### Fixed

- [Anton Davydov] Ensure HTTP Cache to not crash when `HTTP_IF_MODIFIED_SINCE` and `HTTP_IF_NONE_MATCH` have blank values
- [Luca Guidi] Keep flash values after a redirect
- [Craig M. Wellington & Luca Guidi] Ensure to return 404 when `Action#send_file` cannot find a file with a globbed route
- [Luca Guidi] Don't mutate Rack env when sending files

## v1.0.0.beta1 - 2017-02-14

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.4

### Fixed

- [Marcello Rocha & Luca Guidi] Avoid MIME type conflicts for `Action#format` detection
- [Matias H. Leidemer & Luca Guidi] Ensure `Flash` to return only fresh data
- [Luca Guidi] Ensure `session` keys to be accessed as symbols in action unit tests

### Changed

- [Anton Davydov & Luca Guidi] Make it work only with Rack 2.0

## v0.8.1 - 2016-12-19

### Fixed

- [Thorbjørn Hermansen] Don't pollute Rack env's `rack.exception` key if an exception is handled
- [Luca Guidi] Add `flash` to the default exposures

## v0.8.0 - 2016-11-15

### Added

- [Marion Duprey] Allow `BaseParams#get` to read (nested) arrays

### Fixed

- [Russell Cloak] Respect custom formats when referenced by HTTP `Accept`
- [Kyle Chong] Don't symbolize raw params

### Changed

- [Luca Guidi] Let `BaseParams#get` to accept a list of keys (symbols) instead of string with dot notation (`params.get(:customer, :address, :city)` instead of `params.get('customer.address.city')`)

## v0.7.1 - 2016-10-06

### Added

- [Kyle Chong] Introduced `parsed_request_body` for action
- [Luca Guidi] Introduced `Hanami::Action::BaseParams#each`

### Fixed

- [Ayleen McCann] Use default content type when `HTTP_ACCEPT` is `*/*`
- [Kyle Chong] Don't stringify uploaded files
- [Kyle Chong] Don't stringify params values when not necessary

### Changed

- [akhramov & Luca Guidi] Raise `Hanami::Controller::IllegalExposureError` when try to expose reserved words: `params`, and `flash`.

## v0.7.0 - 2016-07-22

### Added

- [Luca Guidi] Introduced `Hanami::Action::Params#error_messages` which returns a flat collection of full error messages

### Fixed

- [Luca Guidi] Params are deeply symbolized
- [Artem Nistratov] Send only changed cookies in HTTP response

### Changed

- [Luca Guidi] Drop support for Ruby 2.0 and 2.1. Official support for JRuby 9.0.5.0+.
- [Luca Guidi] Param validations now require you to add `hanami-validations` in `Gemfile`.
- [Luca Guidi] Removed "_indifferent access_" for params. Since now on, only symbols are allowed.
- [Luca Guidi] Params are immutable
- [Luca Guidi] Params validations syntax has changed
- [Luca Guidi] `Hanami::Action::Params#errors` now returns a Hash. Keys are symbols representing invalid params, while values are arrays of strings with a message of the failure.
- [Vasilis Spilka] Made `Hanami::Action::Session#errors` public

## v0.6.1 - 2016-02-05

### Changed

- [Anatolii Didukh] Optimise memory usage by freezing MIME types constant

## v0.6.0 - 2016-01-22

### Changed

- [Luca Guidi] Renamed the project

## v0.5.1 - 2016-01-19

### Fixed

- [Alfonso Uceda] Ensure `rack.session` cookie to not be sent twice when both `Lotus::Action::Cookies` and `Rack::Session::Cookie` are used together

## v0.5.0 - 2016-01-12

### Added

- [Luca Guidi] Reference a raised exception in Rack env's `rack.exception`. Compatibility with exception reporting SaaS.

### Fixed

- [Cainã Costa] Ensure Rack environment to be always available for sessions unit tests
- [Luca Guidi] Ensure superclass exceptions to not shadow subclasses during exception handling (eg. `CustomError` handler will take precedence over `StandardError`)

### Changed

- [Luca Guidi] Removed `Lotus::Controller::Configuration#default_format`
- [Cainã Costa] Made `Lotus::Action#session` a public method for improved unit testing
- [Karim Tarek] Introduced `Lotus::Controller::Error` and let all the framework exceptions to inherit from it.

## v0.4.6 - 2015-12-04

### Added

- [Luca Guidi] Allow to force custom headers for responses that according to RFC shouldn't include them (eg 204). Override `#keep_response_header?(header)` in action

## v0.4.5 - 2015-09-30

### Added

- [Theo Felippe] Added configuration entries: `#default_request_format` and `default_response_format`.
- [Wellington Santos] Error handling to take account of inherited exceptions.

### Changed

- [Theo Felippe] Deprecated `#default_format` in favor of: `#default_request_format`.

## v0.4.4 - 2015-06-23

### Added

- [Luca Guidi] Security protection against Cross Site Request Forgery (CSRF).

### Fixed

- [Matthew Bellantoni] Ensure nested params to be correctly coerced to Hash.

## v0.4.3 - 2015-05-22

### Added

- [Alfonso Uceda Pompa & Luca Guidi] Introduced `Lotus::Action#send_file`
- [Alfonso Uceda Pompa] Set automatically `Expires` option for cookies when it's missing but `Max-Age` is present. Compatibility with old browsers.

## v0.4.2 - 2015-05-15

### Fixed

- [Luca Guidi] Ensure `Lotus::Action::Params#to_h` to return `::Hash` at the top level

## v0.4.1 - 2015-05-15

### Fixed

- [Luca Guidi] Ensure proper automatic `Content-Type` working well with Internet Explorer.
- [Luca Guidi] Ensure `Lotus::Action#redirect_to` to return `::String` for Rack servers compatibility.

### Changed

- [Alfonso Uceda Pompa] Prevent `Content-Type` and `Content-Lenght` to be sent when status code requires no body (eg. `204`).
  This is for compatibility with `Rack::Lint`, not with RFC 2016.
- [Luca Guidi] Ensure `Lotus::Action::Params#to_h` to return `::Hash`

## v0.4.0 - 2015-03-23

### Added

- [Erol Fornoles] `Action.use` now accepts a block
- [Alfonso Uceda Pompa] Introduced `Lotus::Controller::Configuration#cookies` as default cookie options.
- [Alfonso Uceda Pompa] Introduced `Lotus::Controller::Configuration#default_headers` as default HTTP headers to return in all the responses.
- [Luca Guidi] Introduced `Lotus::Action::Params#get` as a safe API to access nested params.

### Changed

- [Alfonso Uceda Pompa] `redirect_to` now is a flow control method: it terminates the execution of an action, including the callbacks.

## v0.3.2 - 2015-01-30

### Added

- [Alfonso Uceda Pompa] Callbacks: introduced `append_before` (alias of `before`), `append_after` (alias of `after`), `prepend_before` and `prepend_after`.
- [Alfonso Uceda Pompa] Introduced `Lotus::Action::Params#raw` which returns unfiltered data as it comes from an HTTP request.
- [Alfonso Uceda Pompa] `Lotus::Action::Rack.use` now fully supports Rack middleware, by mounting an internal `Rack::Builder` instance.
- [Simone Carletti] `Lotus::Action::Throwable#halt` now accepts an optional message. If missing it falls back to the corresponding HTTP status message.
- [Steve Hodgkiss] Nested params validation

### Fixed

- [Luca Guidi] Ensure HEAD requests will return empty body
- [Stefano Verna] Ensure HTTP status codes with empty body won't send body and non-entity headers.
- [Luca Guidi] Only dump exceptions in `rack.errors` if handling is turned off, or the raised exception is not managed.
- [Luca Guidi] Ensure params will return coerced values

## v0.3.1 - 2015-01-08

### Added

- [Lasse Skindstad Ebert] Introduced `Action#request` which returns an instance a `Rack::Request` compliant object: `Lotus::Action::Request`.

### Fixed

- [Steve Hodgkiss] Ensure params to return coerced values

## v0.3.0 - 2014-12-23

### Added

- [Luca Guidi] Introduced `Action#request_id` as unique identifier for an incoming HTTP request
- [Luca Guidi] Introduced `Lotus::Controller.load!` as loading framework entry point
- [Kir Shatrov] Allow to define a default charset (`default_charset` configuration)
- [Kir Shatrov] Automatic content type with charset (eg `Content-Type: text/html; charset=utf-8`)
- [Michał Krzyżanowski] Allow to specify custom exception handlers: procs or methods (`exception_handler` configuration)
- [Karl Freeman & Lucas Souza] Introduced HTTP caching (`Cache-Control`, `Last-Modified`, ETAG, Conditional GET, expires)
- [Satoshi Amemiya] Introduced `Action::Params#to_h` and `#to_hash`
- [Luca Guidi] Added `#params` and `#errors` as default exposures
- [Luca Guidi] Introduced complete params validations
- [Luca Guidi & Matthew Bellantoni] Allow to whitelist params
- [Luca Guidi & Matthew Bellantoni] Allow to define custom classes for params via `Action.params`
- [Krzysztof Zalewski] Introduced `Action#format` as query method to introspect the requested mime type
- [Luca Guidi] Official support for Ruby 2.2

### Changed

- [Trung Lê] Renamed `Configuration#modules` to `#prepare`
- [Luca Guidi] Update HTTP status codes to IETF RFC 7231
- [Luca Guidi] When `Lotus::Controller` is included, don't inject code
- [Luca Guidi] Removed `Controller.action` as a DSL to define actions
- [Krzysztof Zalewski] Removed `Action#content_type` in favor of `#format=` which accepts a symbol (eg. `:json`)
- [Fuad Saud] Reduce method visibility where possible (Ruby `private` and `protected`)

### Fixed

- [Luca Guidi] Don't let exposures definition to override existing methods

## v0.2.0 - 2014-06-23

### Added

- [Luca Guidi] Introduced `Controller.configure` and `Controller.duplicate`
- [Luca Guidi] Introduced `Action.use`, that let to use a Rack middleware as a before callback
  – [Luca Guidi] Allow to define a default mime type when the request is `Accept: */*` (`default_format` configuration)
  – [Luca Guidi] Allow to register custom mime types and associate them to a symbol (`format` configuration)
- [Luca Guidi] Introduced `Configuration#handle_exceptions` to associate exceptions to HTTP statuses
- [Damir Zekic] Allow developers to toggle exception handling (`handle_exceptions` configuration)
- [Luca Guidi] Introduced `Controller::Configuration`
- [Luca Guidi] Official support for Ruby 2.1

### Changed

- [Luca Guidi] `Lotus::Action::Params` doesn't inherit from `Lotus::Utils::Hash` anymore
- [Luca Guidi] `Lotus::Action::CookieJar` doesn't inherit from `Lotus::Utils::Hash` anymore
- [Luca Guidi] Make HTTP status messages compliant with IANA and Rack
- [Damir Zekic] Moved `#throw` override logic into `#halt`, which keeps the same semantic

### Fixed

- [Krzysztof Zalewski] Reference exception in `rack.errors`

## v0.1.0 - 2014-02-23

### Added

- [Luca Guidi] Introduced `Action.accept` to whitelist accepted mime types
- [Luca Guidi] Introduced `Action#accept?` as a query method for the current request
- [Luca Guidi] Allow to whitelist handled exceptions and associate them to an HTTP status
- [Luca Guidi] Automatic `Content-Type`
- [Luca Guidi] Use `throw` as a control flow which understands HTTP status
- [Luca Guidi] Introduced opt-in support for HTTP/Rack cookies
- [Luca Guidi] Introduced opt-in support for HTTP/Rack sessions
- [Luca Guidi] Introduced HTTP redirect API
- [Luca Guidi] Introduced callbacks for actions: before and after
- [Luca Guidi] Introduced exceptions handling with HTTP statuses
- [Luca Guidi] Introduced exposures
- [Luca Guidi] Introduced basic actions compatible with Rack
- [Luca Guidi] Official support for Ruby 2.0
