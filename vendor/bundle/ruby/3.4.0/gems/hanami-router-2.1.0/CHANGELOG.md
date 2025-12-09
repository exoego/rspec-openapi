# Hanami::Router

Rack compatible HTTP router for Ruby

## v2.1.0 - 2024-02-27

### Fixed

- [Pat Allan] Fix PATH_INFO and SCRIPT_NAME for Rack apps mounted at the root (keep the leading slash in PATH_INFO, and set SCRIPT_NAME to a blank string)
- [Pat Allan] Process glob routes and mounted apps together, so that the routes can be handled in the user-specified order (previously, a root-mounted app would handle routes even if matching globs were declared earlier)

### Changed

- [Pat Allan] Pass keyword args through to middleware

## v2.1.0.rc3 - 2024-02-16

## v2.1.0.rc2 - 2023-11-08

## v2.1.0.rc1 - 2023-11-02

## v2.1.0.beta1 - 2023-06-29

### Added

- [Tim Riley] Accept `not_allowed_proc:` argument when initializing `Hanami::Router`. This allows
  customisation of the `not_allowed` behavior like for `not_found` (#259)

## v2.0.2 - 2022-12-25

### Added

- [Luca Guidi] Official support for Ruby 3.2

## v2.0.1 - 2022-12-06

### Added

- [Armin, Luca Guidi] Introduce `Hanami::Middleware::BodyParser::FormParser` to parse multipart file upload

### Fixed

- [Luca Guidi] Return HTTP response header `Allow` when returning `405` HTTP status

## v2.0.0 - 2022-11-22

### Fixed

- [Luca Guidi] Don't parse request body when Body Parser already parsed it

## v2.0.0.rc1 - 2022-11-08

### Fixed

- [Luca Guidi] During routes inspection, ensure to print path prefixes for nested named routes

### Changed

- [Benjamin Klotz] `Hanami::Middleware::BodyParser::Parser#parse` (abstract method) to raise `NoMethodError` instead of `NotImplementedError`

## v2.0.0.beta4 - 2022-10-24

### Changed

- [Peter Solnica] `Hanami::Middleware::BodyParser` can be initialized with one or more formats and additional custom mime types per format (`Hanami::Middleware::BodyParser.new(app, [:json, :xml])` or `Hanami::Middleware::BodyParser.new(app, [json: "application/json+scim"])`) (#230)

## v2.0.0.beta2 - 2022-08-16

### Fixed

- [Luca Guidi] [Internal] Ensure `Hanami::Middleware::Error` class is available where it is needed [#225]

## v2.0.0.beta1 - 2022-07-20

### Added

- [Marc Busqué] Introduced `Hanami::Router::Formatter::CSV` for CSV inspection of the routes

### Fixed

- [Marc Busqué] Routes inspection: Don't print empty line after the definition of a `get` route
- [Marc Busqué] Routes inspection: Print `<controller>.<action>` instead of `(proc)`
- [Marc Busqué] Routes inspection: Print `(block)` instead of `NilClass` when inspecting a route block

## v2.0.0.alpha6 - 2022-02-10

### Added

- [Luca Guidi] Official support for MRI 3.1
- [Luca Guidi] Parse non-GET request body and make it available in Rack env under the `router.params` key. For JSON requests, please use `Hanami:::Middleware::JsonParser`

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.6, and 2.7.

## v2.0.0.alpha5 - 2021-05-04

### Added

- [Luca Guidi] Introduced `Hanami::Router#to_inspect` which returns a string blob with all the routes formatted for human readability

## v2.0.0.alpha4 - 2021-01-16

### Added

- [Luca Guidi] Official support for MRI 3.0
- [Luca Guidi] Introduced `Hanami::Middleware::BodyParser::Parser` as superclass for body parsers
- [Paweł Świątkowski] Added `not_found:` option to `Hanami::Router#initialize` to customize HTTP 404 status

## v2.0.0.alpha3 - 2020-05-20

### Fixed

- [Luca Guidi] `Hanami::Router#initialize` do not yield block if not given
- [Luca Guidi] Ensure to not accidentally cache response headers for HTTP 404 and 405
- [Luca Guidi] Ensure scoped root to not be added as trailing slash

## v2.0.0.alpha2 - 2020-02-19

### Added

- [Luca Guidi] Block syntax. Routes definition accept a block which returning value is the body of the Rack response.
- [Luca Guidi] Added `resolver:` option to `Hanami::Router#initialize` to provide your own strategy to load endpoints.

### Changed

- [Luca Guidi] Removed `Hanami::Router#resource` and `#resources`.
- [Luca Guidi] Removed loading of routes endpoints.
- [Luca Guidi] Removed `inflector:` from `Hanami::Router#initialize`
- [Luca Guidi] Removed `scheme:`, `host:`, `port:` from `Hanami::Router#initialize`, use `base_url:` instead.

## v2.0.0.alpha1 - 2019-01-30

### Added

- [Luca Guidi] Introduce `Hanami::Router#scope` to support single routing tier for Hanami
- [Semyon Pupkov] Added `inflector:` option for `Hanami::Router#initialize` based on `dry-inflector`

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.3, and 2.4.
- [Luca Guidi] Renamed `Hanami::Router#namespace` => `#prefix`
- [Gustavo Caso] Remove body cleanup for `HEAD` requests
- [Semyon Pupkov] Remove the ability to force SSL (`force_ssl:` option for `Hanami::Router#initialize`)
- [Gustavo Caso] Remove router body parsers (`parsers:` option for `Hanami::Router#initialize`)
- [Luca Guidi] Globbed path requires named capture (was `get "/files/*"`, now is `get "/files/*names"`)
- [Luca Guidi] Router is frozen after initialization
- [Luca Guidi] All the code base respects the frozen string pragma
- [Luca Guidi] `Hanami::Router#initialize` requires `configuration:` option if routes endpoints are `Hanami::Action` subclasses

## v1.3.2 - 2019-02-13

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.7
- [Luca Guidi] Support `rack` 2.1

## v1.3.1 - 2019-01-18

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

## v1.3.0 - 2018-10-24

### Fixed

- [Tim Riley] Skip attempting to parse unknown types in `Hanami::Middleware::BodyParser`

## v1.3.0.beta1 - 2018-08-08

### Added

- [Luca Guidi] Official support for JRuby 9.2.0.0
- [Gustavo Caso] Introduce `Hanami::Middleware::BodyParser` Rack middleware to parse payload of non-GET HTTP requests.

### Deprecated

- [Alfonso Uceda] Deprecate `Hanami::Router.new(force_ssl: true)`. Use webserver (eg. Nginx), Rack middleware (eg. `rack-ssl`), or another strategy to force HTTPS connection.
- [Gustavo Caso] Deprecate `Hanami::Router.new(body_parsers: [:json])`. Use `Hanami::Middleware::BodyParser` instead.

## v1.2.0 - 2018-04-11

## v1.2.0.rc2 - 2018-04-06

## v1.2.0.rc1 - 2018-03-30

## v1.2.0.beta2 - 2018-03-23

## v1.2.0.beta1 - 2018-02-28

## v1.1.1 - 2018-02-27

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.5

### Fixed

- [malin-as] Ensure `Hanami::Router` to properly respond to `unlink`

## v1.1.0 - 2017-10-25

## v1.1.0.rc1 - 2017-10-16

### Added

- [Sergey Fedorov] Allow Rack applications to be mounted inside a namespace. (`namespace "api" { mount V1::App, at: "/v1" }`)

## v1.1.0.beta3 - 2017-10-04

## v1.1.0.beta2 - 2017-10-03

## v1.1.0.beta1 - 2017-08-11

## v1.0.1 - 2017-07-10

### Added

- [Luca Guidi] Introduce new introspection methods (`#redirect?` and `#redirection_path`) for recognized routes (see `Hanami::Router#recognize`)

### Fixed

- [Luca Guidi] Ensure `Hanami::Router#redirect` to be compatible with `#recognize`

## v1.0.0 - 2017-04-06

## v1.0.0.rc1 - 2017-03-31

## v1.0.0.beta3 - 2017-03-17

## v1.0.0.beta2 - 2017-03-02

### Fixed

- [Valentyn Ostakh] Deep symbolize params from parsed body
- [Luca Guidi] `Hanami::Router#recognize` must return a non-routeable object when the endpoint cannot be resolved

## v1.0.0.beta1 - 2017-02-14

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.4
- [Jakub Pavlík] Added `:as` option for RESTful resources (eg. `resources :psi, controller: 'dogs', as: 'dogs'`)

### Changed

- [Pascal Betz] Make compatible with Rack 2.0 only

## v0.8.1 - 2016-11-18

### Fixed

- [Luca Guidi] Ensure JSON body parser to not eval untrusted input

## v0.8.0 - 2016-11-15

### Added

- [Kyle Chong] Referenced params from body parses in Rack env via `router.parsed_body`

### Fixed

- [Luca Guidi & Lucas Hosseini] Ensure params from routes take precedence over params from body parsing
- [Luca Guidi] Ensure inspector to respect path prefix of mouted apps

### Changed

- [Luca Guidi] Official support for Ruby: MRI 2.3+ and JRuby 9.1.5.0+

## v0.7.0 - 2016-07-22

### Added

- [Sean Collins] Introduced `Hanami::Router#root`. Example: `root to: 'home#index'`, equivalent to `get '/', to: 'home#index', as: :root`.
- [Nicola Racco] Allow to mount Rack applications at a specific host. Example: `mount Blog, host: 'blog'`, which will be hit for `GET http://blog.example.com`
- [Luca Guidi] Support `multi_json` gem as backend for JSON body parser. If `multi_json` is present in the gem bundle, it will be used, otherwise it will fallback to Ruby's `JSON`.
- [Luca Guidi] Introduced `Hanami::Routing::RecognizedRoute#path` in order to allow a better introspection

### Fixed

- [Andrew De Ponte] Make routes inspection to work when non-Hanami apps are mounted
- [Andrew De Ponte] Ensure to set the right `SCRIPT_NAME` in Rack env for mounted Hanami apps
- [Luca Guidi] Fix `NoMethodError` when `Hanami::Router#recognize` is invoked with a Rack env or a route name or a path that can't be recognized

### Changed

– [Luca Guidi] Drop support for Ruby 2.0 and 2.1. Official support for JRuby 9.0.5.0+

## v0.6.2 - 2016-02-05

### Fixed

- [Anton Davydov] Fix double leading slash for Capybara's `current_path`

## v0.6.1 - 2016-01-27

### Fixed

- [Luca Guidi] Fix body parsers for non Hash requests

## v0.6.0 - 2016-01-22

### Changed

- [Luca Guidi] Renamed the project

## v0.5.1 - 2016-01-19

- [Anton Davydov] Print stacked lines for routes inspection

## v0.5.0 - 2016-01-12

### Added

- [Luca Guidi] Added `Lotus::Router#recognize` as a testing facility. Example `router.recognize('/') # => associated route`
- [Luca Guidi] Added `Lotus::Router.define` in order to wrap routes definitions in `config/routes.rb` when `Lotus::Router` is used outside of Lotus projects
- [David Strauß] Make `Lotus::Routing::Parsing::JsonParser` compatible with `application/vnd.api+json` MIME Type
- [Alfonso Uceda Pompa] Improved exception messages for `Lotus::Router#path` and `#url`

### Fixed

- [Alfonso Uceda Pompa] Ensure `Lotus::Router#path` and `#url` to generate correct URL for mounted applications
- [Vladislav Zarakovsky] Ensure Force SSL mode to respect Rack SPEC

### Changed

- [Alfonso Uceda Pompa] A failure for body parsers raises a `Lotus::Routing::Parsing::BodyParsingError` exception
- [Karim Tarek] Introduced `Lotus::Router::Error` and let all the framework exceptions to inherit from it.

## v0.4.3 - 2015-09-30

### Added

- [Luca Guidi] Official support for JRuby 9k+

## v0.4.2 - 2015-07-10

### Fixed

- [Alfonso Uceda Pompa] Ensure mounted applications to not repeat their prefix (eg `/admin/admin`)
- [Thiago Felippe] Ensure router inspector properly prints routes with repeated entries (eg `/admin/dashboard/admin`)

## v0.4.1 - 2015-06-23

### Added

- [Alfonso Uceda Pompa] Force SSL (eg `Lotus::Router.new(force_ssl: true`).
- [Alfonso Uceda Pompa] Allow router to accept a `:prefix` option, in order to generate prefixed routes.

## v0.4.0 - 2015-05-15

### Added

- [Alfonso Uceda Pompa] Nested RESTful resource(s)

### Changed

- [Alfonso Uceda Pompa] RESTful resource(s) have a correct pluralization/singularization for variables and named routes (eg. `/books/:id` is now `:book` instead of `:books`)

## v0.3.0 - 2015-03-23

## v0.2.1 - 2015-01-30

### Added

- [Alfonso Uceda Pompa] Lotus::Action compat: invoke `.call` if defined, otherwise fall back to `#call`.

## v0.2.0 - 2014-12-23

### Added

- [Luca Guidi & Alfonso Uceda Pompa] Introduced routes inspector for CLI
- [Luca Guidi & Janko Marohnić] Introduced body parser for JSON
- [Luca Guidi] Introduced request body parsers: they parse body and turn into params.
- [Fred Wu] Introduced Router#define

### Fixed

- [Luca Guidi] Fix for member/collection actions in RESTful resource(s): allow to take actions with a leading slash.
- [Janko Marohnić] Fix for nested namespaces and RESTful resource(s) under namespace. They were generating wrong route names.
- [Luca Guidi] Made InvalidRouteException to inherit from StandardError so it can be catched from anonymous `rescue` clause
- [Luca Guidi] Fix RESTful resource(s) to respect :only/:except options

### Changed

- [Luca Guidi] Aligned naming conventions with Lotus::Controller: no more BooksController::Index. Use Books::Index instead.
- [Luca Guidi] Removed `:prefix` option for routes. Use `#namespace` blocks instead.
- [Janko Marohnić] Make 301 the default redirect status

## v0.1.1 - 2014-06-23

### Added

- [Luca Guidi] Introduced Lotus::Router#mount
- [Luca Guidi] Let specify a pattern for Lotus::Routing::EndpointResolver
- [Luca Guidi] Make Lotus::Routing::Endpoint::EndpointNotFound to inherit from StandardError, instead of Exception. This make it compatible with Rack::ShowExceptions.

## v0.1.0 - 2014-01-23

### Added

- [Luca Guidi] Official support for Ruby 2.1
- [Luca Guidi] Added support for OPTIONS HTTP verb
- [Luca Guidi] Added Lotus::Routing::EndpointNotFound when a lazy endpoint can't be found
- [Luca Guidi] Make action separator customizable via Lotus::Router options.
- [Luca Guidi] Catch http_router exceptions and re-raise them with names under Lotus::Routing. This helps to have a stable public API.
- [Luca Guidi] Lotus::Routing::Resource::CollectionAction use configurable controller and action name separator over the hardcoded value
- [Luca Guidi] Implemented Lotus::Routing::Namespace#resource
- [Luca Guidi] Lotus::Routing::EndpointResolver now accepts options to inject namespace and suffix
- [Luca Guidi] Allow resolver and route class to be injected via options
- [Luca Guidi] Return 404 for not found and 405 for unacceptable HTTP method
- [Luca Guidi] Allow non-finished Rack responses to be used
- [Luca Guidi] Implemented lazy loading for endpoints
- [Luca Guidi] Implemented Lotus::Router.new to take a block and define routes
- [Luca Guidi] Add support for resource
- [Luca Guidi] Support for resource's member and collection
- [Luca Guidi] Add support for namespaces
- [Luca Guidi] Added support for RESTful resources
- [Luca Guidi] Add support for POST, DELETE, PUT, PATCH, TRACE
- [Luca Guidi] Routes constraints
- [Luca Guidi] Named urls
- [Luca Guidi] Added support for Procs as endpoints
- [Luca Guidi] Implemented redirect
- [Luca Guidi] Basic routing
