# Hanami::CLI

Hanami Command Line Interface

## Unreleased

## v2.3.3 - 2025-12-04

- Support the newly released Bundler v4 by removing the upper version bound from our dependency. (@timriley in #373)

## v2.3.2 - 2025-11-16

### Fixed

- Fix potential deadlocks with `db structure dump` for large structure files. (@timriley in #370, report from @pat in #369)
- Decouple the hanami-assets npm package version from the current Hanami version in generated `package.json`, using the stable minor version (e.g. `^2.3.0`) instead of the exact version (e.g. `^2.3.1`). This allows Hanami patch releases without requiring a corresponding hanami-assets npm package release. (@timriley in #270)

## v2.3.1 - 2025-11-14

### Fixed

- Fix stray wording in `README.md` in new apps. (@davidcelis in #368)

## v2.3.0 - 2025-11-12

### Added

- Generate a `bin/setup` when generating new apps. (@davidcelis in #359)
- Generate `bin/hanami` and `bin/rake` binstubs when generating new apps. (@jaredcwhite in #344)
- Generate a view context class when generating new apps or slices. (@afomera in #350)
- Add `--gem-source` option to `hanami new`, to specify the gem source for your `Gemfile`. For example: `hanami new my_app --gem-source=gem.coop`. (@svooop in #356)

### Changed

- Print a one-time warning when accessing an un-booted slice’s `keys` in the console. (@timriley in #349)
- Add `--boot` flag to `console` command, which boots the Hanami app before loading the console. (@kyleplump in #331)
- In new apps, require dry-operation v1.0.1 in the generated `Gemfile`. This is necessary to pull in a fix required for Hanami’s automatic integration of Dry Operation with the database layer. (@timriley in #351)
- When generating new apps with `--head`, use the new GitHub repo names in the `Gemfile` (`"hanami/hanami-view"` instead of `"hanami/view"`). (@afomera in #354)
- When generating new apps with `--head`, add `"hanami-utils"` to the `Gemfile`. (@timriley in #362)
- In new apps, include a patch-level version (e.g. "~> 2.3.0") for Hanami gems in generated `Gemfile`, ensuring updates to the next minor version are only done intentionally. (@timriley in #367)

### Fixed

- When running `db rollback` in development, also rollback the test database. (@timriley in #355)
- Remove "restrict" and "unrestrict" statements (which constantly change, even if there are no structure changes) from Postgres structure dumps. (@rickenharp in #336)
- Remove "-- Dumped from" version comments from Postgres dumps (which will change based on the local client version). (@davidcelis in #358)
- Check for Postgres database existence in a more robust way. The previous method could fail if both the Postgres username and database name were the same. (@rickenharp in #332)
- Fix structure dump and load for MySQL 9.5.0. (@timriley in #348)
- Preserve Bundler environment variables when commands make system calls. (@robyurkowski in 346)

## v2.3.0.beta2 - 2025-10-17

### Added

- Add `hanami run` command, to run your own code. For example, `hanami run path/to/script.rb` or `hanami run 'puts Hanami.app["repos.user_repo"].all.count'`. (@afomera in #338)

### Changed

- Add `--skip-tests` flag to `generate action` command. (@kyleplump in #335)
- In new apps, updated generated types module to `Dry.Types(default: :strict)`. (@minaslater in #323)
- When generators add routes, add those routes to per-slice routes files (`config/routes.rb` within slice directories) if they exist. (@stephannv in #342)
- Drop support for Ruby 3.1

### Fixed

- Handle mixed case names given to `generate` subcommands. (@cllns in #327)

## v2.3.0.beta1 - 2025-10-03

### Added

- Running `hanami generate` commands within a slice directory will generate the file in that slice (@krzykamil in #298)
- Add `db rollback` command, supporting rolling back a single database at a time. (@krzykamil in #300)
- `console` command loads configured extensions from app config. Add these using e.g. `config.console.include MyModule, AnotherModule` (@alassek in #324)
- `console` command uses REPL engine configured in app config. Set this using e.g. `config.console.engine = :pry`; valid options are `:irb` (default) and `:pry` (@alassek in #324)

### Fixed

- Allow generated `public/400.html` and `public/500.html` to go into source control (@kyleplump in #290)
- Properly show database errors from failed `db drop` commands (@katafrakt in #281)
- Ensure consistent env var loading by disallowing Foreman's own env processing in generated `bin/dev` script (@cflipse in #305)
- Use the configured app inflector (and any custom inflections) for all commands (@timriley in #312)
- For app generated with `hanami new` with `--head`, include `hanami-cli` in the `Gemfile` (@afomera in #328)

### Changed

- Prevent `hanami new` from creating apps with confusing names (currently: "app" or "slice") (@seven1m in #272)
- Provide more helpful instructions in generated app README (@hanarimawi in #273)
- Prevent generators from overwriting files (@maxemitchell in #274, @stephannv in #319)
- Add irb as a gem dependency to avoid default gem warnings (@y-yagi in #294)
- Expand on comments `config/assets.js` and enable customization function by default (@robyurkowski in #293)
- Run `git init` at the end of `hanami new` (@krzykamil in #295)
- Prevent blank lines from showing when generating classes without deep module nesting (@cllns)
- Add `--skip-view` flag to `hanami new` (@kyleplump in #308)
- Support Rack 3 in addition to Rack 2 (for `hanami server` command) (@kyleplump in #289)
- Ensure compatibility with MySQL 9.4's CLI tools in `db structure load` command (@timriley in #315)
- Generated `Rakefile` will load tasks defined in `lib/tasks/` (@AlexanderZagaynov in #318)

## v2.2.1 - 2024-11-12

### Changed

- [Tim Riley] Run a bundle install inside `hanami install`. Combined with first-party extension gems modifying the new app's `Gemfile` via a `before "install"` command hook, this ensures that all necessary gems are installed duringthe `hanami new` command. (#269)

### Fixed

- [Tim Riley] Allow `hanami new` to be called with `--skip-db` (#266)

## v2.2.0 - 2024-11-05

### Changed

- [Kyle Plump] Add `--gateway` optiopn to `generate relation` (#261)
- [Tim Riley] Depend on stable release of dry-operation in new app `Gemfile` (#262)
- [Tim Riley] Depend on newser dry-types with a simpler version constraint in new app `Gemfile` (#263)
- [Adam Lassek] Point to Hanami's own migrations guide from generated migration files (#264)

## v2.2.0.rc1 - 2024-10-29

### Added

- [Tim Riley, François Beausoleil] Generate a `config/db/seeds.rb` file in new apps (#255, #256)

### Changed

- [Tim Riley] Add `--env` and `-e` options to all app commands, for setting the Hanami env (#246)
- [Tim Riley] Keep test database in sync by applying `hanami db` commands to both development and test databases when invoked in development environment (#247)
- [Kyle Plump] Add `--skip-route` flag to `generate action` and `generate slice` commands (#227)
- [Tim Riley] Include a `change do` block in generated migrations (#254)
- [Tim Riley] Generate MySQL database URL in `.env` that works with standard Homebrew MySQL installation (#249)
- [Tim Riley, Adam Lassek] Remove ROM extension boilerplate in operations generated by `hanami new` and `generate operation` (this is now applied automatically) (#240, #252)
- [François Beausoleil] Print a warning when running `db seed` but expected seeds files could not be found (#256)
- [Seb Wilgosz] Only register `generate` subcommands if the relevant gems are bundled (#242)
- [Anderson Saunders] When both IRB and pry are loaded, use IRB as the default engine for `hanami console` (#182)

### Fixed

- [Tim Riley] Fix error dumping structure when there are no migrations (#244)
- [Tim Riley] Stop erroneous misconfigured DB warnings from `hanami db` commands when a database is configured once but shared across sliaces (#253)

## v2.2.0.beta2 - 2024-09-25

### Added

- [Tim Riley] MySQL support for `db` commands (#226)
- [Tim Riley] Support for multiple gateways in `db` commands (#232, #234, #237, #238)

### Changed

- [Kyle Plump, Tim Riley] Delete `.keep` files when generating new files into previously empty directory (#224)
- [Sean Collins] Add `db/*.sqlite` to the `.gitignore` in new apps (#210)
- [Sean Collins] Print warnings for misconfigured databases when running `db` commands (#211)

## v2.2.0.beta1 - 2024-07-16

### Added

- [Sean Collins] Generate db files in `hanami new` and `generate slice`
- [Tim Riley] Add `db` commands: `create`, `drop`, `migrate`, `structure dump` `structure load`, `seed` `prepare`, `version`
- [Tim Riley] Support SQLite and Postgres for `db` commands
- [Sean Collins] Add `generate` commands for db components: `generate migration`, `generate relation`, `generate repo`, `generate struct`
- [Krzysztof] Add `generate component` command
- [Sean Collins] Add `generate operation` command

### Changed

- Drop support for Ruby 3.0

## v2.1.1 - 2024-03-19

### Fixed

- [Ryan Bigg] Properly pass INT signal to child processes when interrupting `hanami assets watch` command

## v2.1.0 - 2024-02-27

### Changed

- [Tim Riley] Underscore slice names in `public/assets/` to avoid naming conflicts with nested asset entry points. In this arrangement, an "admin" slice will have its assets compiled into `public/assets/_admin/`.

## v2.1.0.rc3 - 2024-02-16

### Changed

- [Tim Riley] For `hanami assets` commands, run a separate assets compilation process per slice (in parallel).
- [Tim Riley] Generate compiled assets into separate folders per slice, each with its own `assets.js` manifest file: `public/assets/` for the app, and `public/assets/[slice_name]/` for each slice.
- [Tim Riley] For `hanami assets` commands, directly detect and invoke the `config/assets.js` files. Look for this file within each slice, and fall back to the app-level file.
- [Tim Riley] Do not generate `"scripts": {"assets": "..."}` section in new app's `package.json`.
- [Tim Riley] Subclasses of `Hanami::CLI::Command` receive default args to their `#initialize` methods, and do not need to re-declare default args themselves.
- [Philip Arndt] Alphabetically sort hanami gems in the new app `Gemfile`.

### Fixed

- [Nishiki (錦華)] Strip invalid characters from module name when generating new app.

## v2.1.0.rc2 - 2023-11-08

### Added

- [Tim Riley] Add `--skip-tests` for `hanami generate` commands. This CLI option will skip tests generation.

### Changed

- [Tim Riley] Set `"type": "module"` in package.json, enabling ES modules by default
- [Tim Riley] Rename `config/assets.mjs` to `config/assets.js` (use a plain `.js` file extension)

### Fixed

- [Tim Riley] Use correct helper names in generated app layout
- [Luca Guidi] Ensure to generate apps with correct pre-release version of `hanami-assets` NPM package
- [Sean Collins] Print to stderr NPM installation errors when running `hanami install`
- [Sean Collins] Ensure to install missing gems after `hanami install` is ran

## v2.1.0.rc1 - 2023-11-01

### Added

- [Tim Riley] `hanami new` to generate `bin/dev` as configuration for `hanami dev`
- [Luca Guidi] Introducing `hanami generate part` to generate view parts

### Fixed

- [Luca Guidi] `hanami new` generates a fully documented Puma configuration in `config/puma.rb`

### Changed

- [Tim Riley] `hanami new` generates a `config/assets.mjs` as Assets configuration
- [Tim Riley] `hanami new` generates a leaner `package.json`
- [Tim Riley] `hanami new` doesn't generate a default root route anymore
- [Aaron Moodie & Tim Riley] `hanami new` to generate a redesigned 404 and 500 error pages
- [Luca Guidi] When generating a RESTful action, skip `create`, if `new` is present, and `update`, if `edit` is present

## v2.1.0.beta2 - 2023-10-04

### Added

- [Luca Guidi] `hanami new` generates `Procfile.dev`
- [Luca Guidi] `hanami new` generates basic app assets, if `hanami-assets` is bundled by the app
- [Luca Guidi] `hanami new` accepts `--head` to generate the app using Hanami HEAD version from GitHub
- [Luca Guidi] `hanami generate slice` generates basic slice assets, if `hanami-assets` is bundled by the app
- [Ryan Bigg] `hanami generate action` generates corresponding view, if `hanami-view` is bundled by the app
- [Luca Guidi] `hanami assets compile` to compile assets at the deploy time
- [Luca Guidi] `hanami assets watch` to watch and compile assets at the development time
- [Luca Guidi] `hanami dev` to start the processes in `Procfile.dev`

### Fixed

- [Luca Guidi] `hanami new` generates a `Gemfile` with `hanami-webconsole` in `:development` group
- [Luca Guidi] `hanami new` generates a `Gemfile` with versioned `hanami-webconsole`, `hanami-rspec`, and `hanami-reloader`

## v2.1.0.beta1 - 2023-06-29

### Added

- [Tim Riley] `hanami new` to generate default views, templates, and helpers
- [Tim Riley] `hanami generate slice` to generate default views, templates, and helpers
- [Tim Riley] `hanami generate action` to generate associated view and template
- [Tim Riley] Introduced `hanami generate view`
- [Tim Riley] `hanami new` to generate `Gemfile` with `hanami-view` and `hanami-webconsole` gems
- [Tim Riley] `hanami new` to generate default error pages for `404` and `500` HTTP errors

### Fixed

- [Philip Arndt] `hanami server` to start only one Puma worker by default

## v2.0.3 - 2023-02-01

### Added

- [Luca Guidi] Generate a default `.gitignore` when using `hanami new`

### Fixed

- [dsisnero] Ensure to run automatically bundle gems when using `hanami new` on Windows
- [Luca Guidi] Ensure to generate the correct action identifier in routes when using `hanami generate action` with deeply nested action name

## v2.0.2 - 2022-12-25

### Added

- [Luca Guidi] Official support for Ruby 3.2

## v2.0.1 - 2022-12-06

### Fixed

- [Luca Guidi] Ensure to load `.env` files during CLI commands execution
- [Luca Guidi] Ensure `hanami server` to respect HTTP port used in `.env` or the value given as CLI argument (`--port`)

## v2.0.0 - 2022-11-22

### Added

- [Tim Riley] Use Zeitwerk to autoload the gem

### Fixed

- [Luca Guidi] In case of internal exception, don't print the stack trace to stderr, print the error message, exit with 1.
- [Tim Riley] Ensure to be able to run `hanami` CLI in Hanami app subdirectories.
- [Sean Collins] Return an error when trying to run `hanami new` with an existing target path (file or directory)

## v2.0.0.rc1 - 2022-11-08

## v2.0.0.beta4 - 2022-10-24

### Changed

- [Sean Collins] Show output when generating files (e.g. in `hanami new`) (#49)
- [Luca Guidi] Advertise Bundler and Hanami install steps when running `hanami new` (#54)

## v2.0.0.beta3 - 2022-09-21

### Added

- [Luca Guidi] New applications to support Puma server out of the box. Add the `puma` gem to `Gemfile` and generate `config/puma.rb`.
- [Luca Guidi] New applications to support code reloading for `hanami server` via `hanami-reloader`. This gem is added to app's `Gemfile`.
- [Marc Busqué] Introduce code reloading for `hanami console` via `#reload` method to be invoked within the console context.

### Fixed

- [Luca Guidi] Respect plural when generating code via `hanami new` and `hanami generate`. Example: `hanami new code_insights` => `CodeInsights` instead of `CodeInsight`
- [Luca Guidi] Ensure `hanami generate action` to not crash when invoked with non-RESTful action names. Example: `hanami generate action talent.apply`

### Changed

- [Piotr Solnica] `hanami generate action` to add routes to `config/routes.rb` without the `define` block context. See https://github.com/hanami/hanami/pull/1208

## v2.0.0.beta2 - 2022-08-16

### Added

- [Luca Guidi] Added `hanami generate slice` command, for generating a new slice [#32]
- [Luca Guidi] Added `hanami generate action` command, for generating a new action in the app or a slice [#33]
- [Marc Busqué] Added `hanami middlewares` command, for listing middleware configed in app and/or in `config/routes.rb` [#30]

### Changed

- [Marc Busqué, Tim Riley] `hanami` command will detect the app even when called inside nested subdirectories [#34]
- [Seb Wilgosz] Include hanami-validations in generated app’s `Gemfile`, allowing action classes to specify `.params` [#31]
- [Tim Riley] Include dry-types in generated app’s `Gemfile`, which is used by the types module defined in `lib/[app_name]/types.rb` (dry-types is no longer a hard dependency of the hanami gem as of 2.0.0.beta2) [#29]
- [Tim Riley] Include dotenv in generated app’s `Gemfile`, allowing `ENV` values to be loaded from `.env*` files [#29]

## v2.0.0.beta1 - 2022-07-20

### Added

- [Luca Guidi] Implemented `hanami new` to generate a new Hanami app
- [Piotr Solnica] Implemented `hanami console` to start an interactive console (REPL)
- [Marc Busqué] Implemented `hanami server` to start a HTTP server based on Rack
- [Marc Busqué] Implemented `hanami routes` to print app routes
- [Luca Guidi] Implemented `hanami version` to print app Hanami version

## v2.0.0.alpha8.1 - 2022-05-23

### Fixed

- [Tim Riley] Ensure CLI starts properly by fixing use of `Slice.slice_name`

## v2.0.0.alpha8 - 2022-05-19

### Fixed

- [Andrew Croome] Respect HANAMI_ENV env var to set Hanami env if no `--env` option is supplied
- [Lucas Mendelowski] Ensure Sequel migrations extension is loaded before related `db` commands are run

## v2.0.0.alpha7 - 2022-03-11

### Changed

- [Tim Riley] [Internal] Update console slice readers to work with new `Hanami::Application.slices` API

## v2.0.0.alpha6.1 - 2022-02-11

### Fixed

- [Viet Tran] Ensure `hanami db` commands to work with `hanami` `v2.0.0.alpha6`

## v2.0.0.alpha6 - 2022-02-10

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.1

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.6, and 2.7

## v2.0.0.alpha4 - 2021-12-07

### Added

- [Tim Riley] Display a custom prompt when using irb-based console (consistent with pry-based console)
- [Phil Arndt] Support `postgresql://` URL schemes (in addition to existing `postgres://` support) for `db` subcommands

### Fixed

- [Tim Riley] Ensure slice helper methods work in console (e.g. top-level `main` method will return `Main::Slice` if an app has a "main" slice defined)

## v2.0.0.alpha3 - 2021-11-09

No changes.

## v2.0.0.alpha2 - 2021-05-04

### Added

- [Luca Guidi] Official support for Ruby: MRI 3.0
- [Luca Guidi] Dynamically change the set of available commands depending on the context (outside or inside an Hanami app)
- [Luca Guidi] Dynamically change the set of available commands depending on Hanami app architecture
- [Luca Guidi] Implemented `hanami version` (available both outside and inside an Hanami app)
- [Piotr Solnica] Implemented `db *` commands (available both outside and inside an Hanami app) (sqlite and postgres only for now)
- [Piotr Solnica] Implemented `console` command with support for `IRB` and `Pry` (`pry` is auto-detected)

### Changed

- [Luca Guidi] Changed the purpose of this gem: the CLI Ruby framework has been extracted into `dry-cli` gem. `hanami-cli` is now the `hanami` command line.
- [Luca Guidi] Drop support for Ruby: MRI 2.5.

## v1.0.0.alpha1 - 2019-01-30

### Added

- [Luca Guidi] Inheritng from subclasses of `Hanami::CLI::Command`, allows to inherit arguments, options, description, and examples.
- [Luca Guidi] Allow to use `super` from `#call`

### Changed

- [Luca Guidi] Drop support for Ruby: MRI 2.3, and 2.4.

## v0.3.1 - 2019-01-18

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.6
- [Luca Guidi] Support `bundler` 2.0+

## v0.3.0 - 2018-10-24

## v0.3.0.beta1 - 2018-08-08

### Added

- [Anton Davydov & Alfonso Uceda] Introduce array type for arguments (`foo exec test spec/bookshelf/entities spec/bookshelf/repositories`)
- [Anton Davydov & Alfonso Uceda] Introduce array type for options (`foo generate config --apps=web,api`)
- [Alfonso Uceda] Introduce variadic arguments (`foo run ruby:latest -- ruby -v`)
- [Luca Guidi] Official support for JRuby 9.2.0.0

### Fixed

- [Anton Davydov] Print informative message when unknown or wrong option is passed (`"test" was called with arguments "--framework=unknown"`)

## v0.2.0 - 2018-04-11

## v0.2.0.rc2 - 2018-04-06

## v0.2.0.rc1 - 2018-03-30

## v0.2.0.beta2 - 2018-03-23

### Added

- [Anton Davydov & Luca Guidi] Support objects as callbacks

### Fixed

- [Anton Davydov & Luca Guidi] Ensure callbacks' context of execution (aka `self`) to be the command that is being executed

## v0.2.0.beta1 - 2018-02-28

### Added

- [Anton Davydov] Register `before`/`after` callbacks for commands

## v0.1.1 - 2018-02-27

### Added

- [Luca Guidi] Official support for Ruby: MRI 2.5

### Fixed

- [Alfonso Uceda] Ensure default values for arguments to be sent to commands
- [Alfonso Uceda] Ensure to fail when a missing required argument isn't provider, but an option is provided instead

## v0.1.0 - 2017-10-25

## v0.1.0.rc1 - 2017-10-16

## v0.1.0.beta3 - 2017-10-04

## v0.1.0.beta2 - 2017-10-03

### Added

- [Alfonso Uceda] Allow default value for arguments

## v0.1.0.beta1 - 2017-08-11

### Added

- [Alfonso Uceda, Luca Guidi] Commands banner and usage
- [Alfonso Uceda] Added support for subcommands

- [Alfonso Uceda] Validations for arguments and options
- [Alfonso Uceda] Commands arguments and options
- [Alfonso Uceda] Commands description
- [Alfonso Uceda, Oana Sipos] Commands aliases
- [Luca Guidi] Exit on unknown command
- [Luca Guidi, Alfonso Uceda, Oana Sipos] Command lookup
- [Luca Guidi, Tim Riley] Trie based registry to register commands and allow third-parties to override/add commands
