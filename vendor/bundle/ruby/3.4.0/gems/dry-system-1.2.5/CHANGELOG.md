# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

[Unreleased]: https://github.com/dry-rb/dry-system/compare/v1.2.5...main

## [1.2.5] - 2025-12-01

### Fixed

- Pass through keyword arguments to monitored objects in `monitoring` plugin. (@yuszuv in #290)

[1.2.5]: https://github.com/dry-rb/dry-system/compare/v1.2.4...v1.2.5

## [1.2.4] - 2025-08-14


### Fixed

- Allow imported components to be lazy loaded when both strings and symbols are given as the
namespace to `Container.import` (@timriley in #287)


[Compare v1.2.3...v1.2.4](https://github.com/dry-rb/dry-system/compare/v1.2.3...v1.2.4)

## [1.2.3] - 2025-07-29


### Added

- Add :register after-hook to detect container key registration dynamically. (via #274, @alassek)

### Fixed

- Re-register components from manifest registrars in apps that reload the container (e.g. when
using dry-rails and Rails development mode) (via #286, @alassek)

### Changed

- :finalize after-hook now executes before container freeze to allow mutation. (via #274, @alassek)

[Compare v1.2.2...v1.2.3](https://github.com/dry-rb/dry-system/compare/v1.2.2...v1.2.3)

## [1.2.2] - 2025-01-31


### Fixed

- Syntax errors on 3.3.0 (@flash-gordon, see #284)


[Compare v1.2.1...v1.2.2](https://github.com/dry-rb/dry-system/compare/v1.2.1...v1.2.2)

## [1.2.1] - 2025-01-08


### Fixed

- `eager_load` was removed from `finalize!`. It was introduced with `true` by default that
wasn't the intention #281 (via #282) (@flash-gordon)


[Compare v1.2.0...v1.2.1](https://github.com/dry-rb/dry-system/compare/v1.2.0...v1.2.1)

## [1.2.0] - 2025-01-07


### Added

- Option to skip eager loading during finalize with `eager_load: false` (via #276) (@cllns)

### Changed

- Update required Ruby version to 3.1 (@flash-gordon)

[Compare v1.1.1...v1.2.0](https://github.com/dry-rb/dry-system/compare/v1.1.1...v1.2.0)

## [1.1.1] - 2024-11-03


### Fixed

- Restore `ProviderRegistrar#find_and_load_provider` as an alias of `#[]`


[Compare v1.1.0...v1.1.1](https://github.com/dry-rb/dry-system/compare/v1.1.0...v1.1.1)

## [1.1.0] - 2024-10-31



[Compare v1.1.0.beta2...v1.1.0](https://github.com/dry-rb/dry-system/compare/v1.1.0.beta2...v1.1.0)

## [1.1.0.beta2] - 2024-09-25


### Changed

- Allow provider sources to use a custom superclass. This requires a custom provider registrar
to be configured, with its own implementations of `#provider_source_class` (the superclass to
use) and `#provider_source_options` (custom initialization args to pass to the provider
source). (via #275) (@alassek, @timriley)

[Compare v1.1.0.beta1...v1.1.0.beta2](https://github.com/dry-rb/dry-system/compare/v1.1.0.beta1...v1.1.0.beta2)

## [1.1.0.beta1] - 2024-07-03


### Added

- Add `Dry::System::ProviderRegistrar#target_container`, to be passed when initializing
providers. By default this is an alias of `#container`. This allows for custom provider
registrars to override `#target_container` to provide a custom `#target` within providers.
An overridden value **MUST** still wrap the original `#target_container` to ensure components
are registered in the right place. (via #270) (@timriley)

### Changed

- Make `Dry::System::ProviderRegistrar` public API (via #270) (@timriley)
- When registering a provider source, you can now provide a `provider_options:` hash of default
options for providers to be registered using that source. The one provider option currently
supported is `namespace:`. (via #271) (@timriley)
- Load providers when accessing them via `Dry::System::ProviderRegistrar#[]`. The previous,
behavior of `#[]` returning `nil` if a provider had not been explicitly loaded was a
potential source of confusion. Now `#[]` can serve as the one and only interface for fetching
a provider. (via #273) (@timriley)

[Compare v1.0.1...v1.1.0.beta1](https://github.com/dry-rb/dry-system/compare/v1.0.1...v1.1.0.beta1)

## [1.0.1] - 2022-11-18


### Changed

- Bumped dry-auto_inject dependency to its 1.0.0 final release (@solnic)

[Compare v1.0.0...v1.0.1](https://github.com/dry-rb/dry-system/compare/v1.0.0...v1.0.1)

## [1.0.0] - 2022-11-18


### Fixed

- Only use DidYouMean-integrated Error for Component loading failure (via #261) (@cllns + @solnic)

### Changed

- This version uses dry-core 1.0 and dry-configurable 1.0 (@solnic + @flash-gordon)
- Raise error on import after finalize (via #254) (@timriley + @tak1n)
- Validate settings even if loader does not set value (via #246) (@oeoeaio)
- Remove all deprecated functionality and deprecation messages (via #255) (@timriley)
- Use main dry/monitor entrypoint for autoloading (via #257) (@timriley)
- Use dry-configurable 1.0 (via 43c79095ccf54c6251e825ae20c97a9415e78209) (@flash-gordon)
- Use dry-core 1.0 (via 3d0cf95aef120601e67f3e8fbbf16d004017d376) (@flash-gordon)
- Remove dry-container dependency and update to use `Dry::Core::Container` (via 2b76554e5925fc92614627d5c1e0a9177cecf12f) (@solnic)

[Compare v0.27.2...v1.0.0](https://github.com/dry-rb/dry-system/compare/v0.27.2...v1.0.0)

## [0.27.2] - 2022-10-17


### Fixed

- Removed remaining manual require left-overs (@solnic)


[Compare v0.27.1...v0.27.2](https://github.com/dry-rb/dry-system/compare/v0.27.1...v0.27.2)

## [0.27.1] - 2022-10-15


### Fixed

- Tweak for zeitwerk loader (@flash-gordon)


[Compare v0.27.0...v0.27.1](https://github.com/dry-rb/dry-system/compare/v0.27.0...v0.27.1)

## [0.27.0] - 2022-10-15


### Changed

- [BREAKING] Use zeitwerk for auto-loading dry-system (@flash-gordon + @solnic)

From now on you need to do `require "dry/system"` as it sets up its Zeitwerk loader and from
there, everything else will be auto-loaded.

[Compare v0.26.0...v0.27.0](https://github.com/dry-rb/dry-system/compare/v0.26.0...v0.27.0)

## [0.26.0] - 2022-10-08


### Changed

- Update dry-configurable dependency to 0.16.0 and make internal adjustments to suit (@timriley in #249)
- Remove now-unused concurrent-ruby gem dependency (@timriley in #250)

[Compare v0.25.0...v0.26.0](https://github.com/dry-rb/dry-system/compare/v0.25.0...v0.26.0)

## [0.25.0] - 2022-07-10


### Fixed

- Fix incorrect type in `ManifestRegistrar#finalize!` (@alassek)

### Changed

- Import root components via `nil` import namespace (via #236) (@timriley)
- Allow deeper `Provider::Source` hierarchies (via #240) (@timriley + @solnic)
- Prefer local components when importing (via #241) (@timriley  + @solnic)

[Compare v0.24.0...v0.25.0](https://github.com/dry-rb/dry-system/compare/v0.24.0...v0.25.0)

## [0.24.0] - 


### Changed

- dry-struct depedency was removed (@flash-gordon)

[Compare v0.23.0...master](https://github.com/dry-rb/dry-system/compare/v0.23.0...master)

## [0.23.0] - 2022-02-08

This is a major overhaul of bootable components (now known as “Providers”), and brings major advancements to other areas, including container imports and exports.

Deprecations are in place for otherwise breaking changes to commonly used parts of dry-system, though some breaking changes remain.

This prepares the way for dry-system 1.0, which will be released in the coming months.


### Added

- Containers can configure specific components for export using `config.exports` (@timriley in #209).

  ```ruby
  class MyContainer < Dry::System::Container
    configure do |config|
      config.exports = %w[component_a component_b]
    end
  end
  ```

  Containers importing another container with configured exports will import only those components.

  When importing a specific set of components (see the note in the “Changed” section below), only those components whose keys intersect with the configured exports will be imported.
- A `:zeitwerk` plugin, to set up [Zeitwerk](https://github.com/fxn/zeitwerk) and integrate it with your container configuration (@ianks and @timriley in #197, #222, 13f8c87, #223)

  This makes it possible to enable Zeitwerk with a one-liner:

  ```ruby
  class MyContainer < Dry::System::Container
    use :zeitwerk

    configure do |config|
      config.component_dirs.add "lib"
      # ...
    end
  end
  ```

  The plugin makes a `Zeitwerk::Loader` instance available at `config.autoloader`, and then in an after-`:configure` hook, the plugin will set up the loader to work with all of your configured component dirs and their namespaces. It will also enable the `Dry::System::Loader::Autoloading` loader for all component dirs, plus disable those dirs from being added to the `$LOAD_PATH`.

  The plugin accepts the following options:

  - `loader:` - (optional) to use a pre-initialized loader, if required.
  - `run_setup:` - (optional) a bool to determine whether to run `Zeitwerk::Loader#setup` as part of the after-`:configure` hook. This may be useful to disable in advanced cases when integrating with an externally managed loader.
  - `eager_load:` - (optional) a bool to determine whether to run `Zeitwerk::Loader#eager_load` as part of an after-`:finalize` hook. When not provided, it will default to true if the `:env` plugin is enabled and the env is set to `:production`.
  - `debug:` - (optional) a bool to set whether Zeitwerk should log to `$stdout`.
- New `Identifier#end_with?` and `Identifier#include?` predicates (@timriley in #219)

  These are key segment-aware predicates that can be useful when checking components as part of container configuration.

  ```ruby
  identifier.key # => "articles.operations.create"

  identifier.end_with?("create") # => true
  identifier.end_with?("operations.create") # => true
  identifier.end_with?("ate") # => false, not a whole segment
  identifier.end_with?("nope") # => false, not part of the key at all

  identifier.include?("operations") # => true
  identifier.include?("articles.operations") # => true
  identifier.include?("operations.create") # => true
  identifier.include?("article") # false, not a whole segment
  identifier.include?("update") # => false, not part of the key at all
  ```
- An `instance` setting for component dirs allows simpler per-dir control over component instantiation (@timriley in #215)

  This optional setting should be provided a proc that receives a single `Dry::System::Component` instance as an argument, and should return the instance for the given component.

  ```ruby
  configure do |config|
    config.component_dirs.add "lib" do |dir|
      dir.instance = proc do |component|
        if component.identifier.include?("workers")
          # Register classes for jobs
          component.loader.constant(component)
        else
          # Otherwise register regular instances per default loader
          component.loader.call(component)
        end
      end
    end
  end
  ```

  For complete control of component loading, you should continue to configure the component dir’s `loader` instead.
- A new `ComponentNotLoadableError` error and helpful message is raised when resolving a component and an unexpected class is defined in the component’s source file (@cllns in #217).

  The error shows expected and found class names, and inflector configuration that may be required in the case of class names containing acronyms.

### Fixed

- Registrations made in providers (by calling `register` inside a provider step) have all their registration options preserved (such as a block-based registration, or the `memoize:` option) when having their registration merged into the target container after the provider lifecycle steps complete (@timriley in #212).
- Providers can no longer implicitly re-start themselves while in the process of starting and cause an infinite loop (@timriley #213).

  This was possible before when a provider resolved a component from the target container that auto-injected dependencies with container keys sharing the same base key as the provider name.

### Changed

- “Bootable components” (also referred to in some places simply as “components”) have been renamed to “Providers” (@timriley in #200).

  Register a provider with `Dry::System::Container.register_provider` (`Dry::System::Container.boot` has been deprecated):

  ```ruby
  MyContainer.register_provider(:mailer) do
    # ...
  end
  ```
- Provider `init` lifecycle step has been deprecated and renamed to `prepare` (@timriley in #200).

  ```ruby
  MyContainer.reigster_provider(:mailer) do
    # Rename `init` to `prepare`
    prepare do
      require "some/third_party/mailer"
    end
  end
  ```
- Provider behavior is now backed by a class per provider, known as the “Provider source” (@timriley in #202).

  The provider source class is created for each provider as a subclass of `Dry::System::Provider::Source`.

  You can still register simple providers using the block-based DSL, but the class backing means you can share state between provider steps using regular instance variables:

  ```ruby
  MyContainer.reigster_provider(:mailer) do
    prepare do
      require "some/third_party/mailer"
      @some_config = ThirdParty::Mailer::Config.new
    end

    start do
      # Since the `prepare` step will always run before start, we can access
      # @some_config here
      register "mailer", ThirdParty::Mailer.new(@some_config)
    end
  end
  ```

  Inside this `register_provider` block, `self` is the source subclass itself, and inside each of the step blocks (i.e. `prepare do`), `self` will be the _instance_ of that provider source.

  For more complex providers, you can define your own source subclass and register it directly with the `source:` option for `register_provider`. This allows you to more readily use standard arrangements for factoring your logic within a class, such as extraction to another method:

  ```ruby
  MyContainer.register_provider(:mailer, source: Class.new(Dry::System::Provider::Source) {
    # The provider lifecycle steps are ordinary methods
    def prepare
    end

    def start
      mailer = some_complex_logic_to_build_the_mailer(some: "config")
      register(:mailer, mailer)
    end

    private

    def some_complex_logic_to_build_the_mailer(**options)
      # ...
    end
  })
  ```
- The block argument to `Dry::System::Container.register_provider` (previously `.boot`) has been deprecated. (@timriley in #202).

  This argument was used to give you access to the provider's target container (i.e. the container on which you were registering the provider).

  To access the target container, you can use `#target_container` (or `#target` as a convenience alias) instead.

  You can also access the provider's own container (which is where the provider's components are registered when you call `register` directly inside a provider step) as `#provider_container` (or `#container` as a convenience alias).
- `use(provider_name)` inside a provider step has been deprecated. Use `target_container.start(provider_name)` instead (@timriley in #211 and #224)

  Now that you can access `target_container` consistently within all provider steps, you can use it to also start any other providers as you require without any special additional method. This also allows you to invoke other provider lifecycle steps, like `target_container.prepare(provider_name)`.
- `method_missing`-based delegation within providers to target container registrations has been removed (**BREAKING**) (@timriley in #202)

  Delegation to registrations with the provider's own container has been kept, since it can be a convenient way to access registrations made in a prior lifecycle step:

  ```ruby
  MyContainer.register_provider(:mailer, namespace: true) do
    prepare do
      register :config, "mailer config here"
    end

    start do
      config # => "mailer config here"
    end
  end
  ```
- The previous "external component" and "provider" concepts have been renamed to "external provider sources", in keeping with the new provider terminology outlined above (@timriley in #200 and #202).

  You can register a collection of external provider sources defined in their own source files via `Dry::System.register_provider_sources` (`Dry::System.register_provider` has been deprecated):

  ```ruby
  require "dry/system"

  Dry::System.register_provider_sources(path)
  ```

  You can register an individual external provider source via `Dry::System.register_provider_source` (`Dry::System.register_component` has been deprecated):

  ```ruby
  Dry::System.register_provider_source(:something, group: :my_gem) do
    start do
      # ...
    end
  end
  ```

  Just like providers, you can also register a class as an external provider source:

  ```ruby
  module MyGem
    class MySource < Dry::System::Provider::Source
      def start
        # ...
      end
    end
  end

  Dry::System.register_provider_source(:something, group: :my_gem, source: MyGem::MySource)
  ```

  The `group:` argument when registering an external provider sources is for preventing name clashes between provider sources. You should use an underscored version of your gem name or namespace when registering your own provider sources.
- Registering a provider using an explicitly named external provider source via `key:` argument is deprecated, use the `source:` argument instead (@timriley in #202).

  You can register a provider using the same name as an external provider source by specifying the `from:` argument only, as before:

  ```ruby
  # Elsewhere
  Dry::System.register_provider_source(:something, group: :my_gem) { ... }

  # In your app:
  MyContainer.register_provider(:something, from: :my_gem)
  ```

  When you wish the name your provider differently, this is when you need to use the `source:` argument:

  ```ruby
  MyContainer.register_provider(:differently_named, from: :my_gem, source: :something)
  ```

  When you're registering a provider using an external provider source, you cannot provie your own `Dry::System::Provider::Source` subclass as the `source:`, since that source class is being provided by the external provider source.
- Provider source settings are now defined using dry-configurable’s `setting` API at the top-level scope (@timriley in #202).

  Use the top-level `setting` method to define your settings (the `settings` block and settings defined inside the block using `key` is deprecated). Inside the provider steps, the configured settings can be accessed as `config`:

  ```ruby
  # In the external provider source
  Dry::System.register_provider_source(:something, group: :my_gem) do
    setting :my_option

    start do
      # Do something with `config.my_option` here
    end
  end
  ```

  When using an external provider source, configure the source via the `#configure`:

  ```ruby
  # In your application's provider using the external source
  MyContainer.register_provider(:something, from: :my_gem) do
    configure do |config|
      config.my_option = "some value"
    end
  end
  ```

  To provide default values and type checking or constraints for your settings, use the dry-configurable’s `default:` and `constructor:` arguments:

  ```ruby
  # Constructor can take any proc being passed the provided value
  setting :my_option, default: "hello", constructor: -> (v) { v.to_s.upcase }

  # Constructor will also work with dry-types objects
  setting :my_option, default: "hello", constructor: Types::String.constrained(min_size: 3)
  ```
- External provider sources can define their own methods for use by the providers alongside lifecycle steps (@timriley in #202).

  Now that provider sources are class-backed, external provider sources can define their own methods to be made available when that provider source is used. This makes it possible to define your own extended API for interacting with the provider source:

  ```ruby
  # In the external provider source

  module MyGem
    class MySource < Dry::System::Provider::Source
      # Standard lifecycle steps
      def start
        # Do something with @on_start here
      end

      # Custom behavior available when this provider source is used in a provider
      def on_start(&block)
        @on_start = block
      end
    end
  end

  Dry::System.register_provider_source(:something, group: :my_gem, source: MyGem::MySource)

  # In your application's provider using the external source

  MyContainer.register_provider(:something, from: :my_gem) do
    # Use the custom method!
    on_start do
      # ...
    end
  end
  ```
- Providers can be registered conditionally using the `if:` option (@timriley in #218).

  You should provide a simple truthy or falsey value to `if:`, and in the case of falsey value, the provider will not be registered.

  This is useful in cases where you have providers that are loaded explicitly for specific runtime configurations of your app (e.g. when they are needed for specific tasks or processes only), but you do not need them for your primaary app process, for which you may finalize your container.
- `bootable_dirs` container setting has been deprecated and replaced by `provider_dirs` (@timriley in #200).

  The default value for `provider_dirs` is now `"system/providers`".
- Removed the unused `system_dir` container setting (**BREAKING**) (@timriley in #200)

  If you’ve configured this inside your container, you can remove it.
- dry-system’s first-party external provider sources now available via `require "dry/system/provider_sources"`, with the previous `require "dry/system/components"` deprecated (@timriley in #202).
- When using registering a provider using a first-party dry-system provider source, `from: :dry_system` instead of `from: :system` (which is now deprecated) (@timriley in #202).

  ```ruby
  MyContainer.register_provider(:settings, from: :dry_system) do
    # ...
  end
- When registering a provider using the `:settings` provider source, settings are now defined using `setting` inside a `settings` block, rather than `key`, which is deprecated (@timriley in #202).

  This `setting` method uses the dry-configurable setting API:

  ```ruby
  MyContainer.register_provider(:settings, from: :dry_system) do
    settings do
      # Previously:
      # key :my_int_setting, MyTypes::Coercible::Integer

      # Now:
      setting :my_setting, default: 0, constructor: MyTypes::Coercible::Integer
    end
  end
  ```
- The `:settings` provider source now requires the dotenv gem to load settings from `.env*` files (**BREAKING**) (@timriley in #204)

  To ensure you can load your settings from these `.env*` files, add `gem "dotenv"` to your `Gemfile`.
- `Dry::System::Container` can be now be configured direclty using the setting writer methods on the class-level `.config` object, without going the `.configure(&block)` API (@timriley in #207).

   If configuring via the class-level `.config` object, you should call `.configured!` after you're completed your configuration, which will finalize (freeze) the `config` object and then run any after-`:configure` hooks.
- `Dry::System::Container.configure(&block)` will now finalize (freeze) the `config` object by default, before returning (@timriley in #207).

  You can opt out of this behavior by passing the `finalize_config: false` option:

  ```ruby
  class MyContainer < Dry::System::Container
    configure(finalize_config: false) do |config|
      # ...
    end

    # `config` is still non-finalized here
  end
  ```
- `Dry::System::Container.finalize!` will call `.configured!` (if it has not yet been called) before doing its work (@timriley in #207)

  This ensures config finalization is an intrinsic part of the overall container finalization process.
- The `Dry::System::Container` `before(:configure)` hook has been removed (**BREAKING**) (@timriley in #207).

  This was previously used for plugins to register their own settings, but this was not necessary given that plugins are modules, and can use their ordinary `.extended(container_class)` hook to register their settings. Essentially, any time after container subclass definition is "before configure" in nature.
- Container plugins should define their settings on the container using their module `.extended` hook, no longer in a `before(:configure)` hook (as above) (**BREAKING**) (@timriley in #207).

  This ensures the plugin settings are available immediately after you’ve enabled the plugin via `Dry::System::Container.use`.
- The `Dry::System::Container` key `namespace_separator` setting is no longer expected to be user-configured. A key namespace separator of "." is hard-coded and expected to remain the separator string. (@timriley in #206)
- Containers can import a specific subset of another container’s components via changes to `.import`, which is now `.import(keys: nil, from:, as:)` (with prior API deprecated) (@timriley in #209)

  To import specific components:

  ```ruby
  class MyContainer < Dry::System::Container
    # config, etc.

    # Will import components with keys "other.component_a", "other.component_b"
    import(
      keys: %w[component_a component_b],
      from: OtherContainer,
      as: :other
    )
  ```

  Omitting `keys:` will import all the components available from the other container.
- Components imported into a container from another will be protected from subsequent export unless explicitly configured in `config.exports` (@timriley in #209)

  Imported components are considered “private” by default because they did not originate in container that imported them.

  This ensures there are no redundant imports in arrangements where multiple all containers import a common “base” container, and then some of those containers then import each other.
- Container imports are now made without finalizing the exporting container in most cases, ensuring more efficient imports (@timriley in #209)

  Now, the only time the exporting container will be finalized is when a container is importing all components, and the exporting container has not declared any components in `config.exports`.
- [Internal] The `manual_registrar` container setting and associated `ManualRegistrar` class have been renamed to `manifest_registrar` and `ManifestRegistrar` respectively (**BREAKING**) (@timriley in #208).
- The default value for the container `registrations_dir` setting has been changed from `"container"` to `"system/registrations"` (**BREAKING**) (@timriley in #208)
- The `:dependency_graph` plugin now supports all dry-auto_inject injector strategies (@davydovanton and @timriley in #214)

[Compare v0.22.0...v0.23.0](https://github.com/dry-rb/dry-system/compare/v0.22.0...v0.23.0)

## [0.22.0] - 2022-01-06


### Added

- Expanded public interfaces for `Dry::System::Config::ComponentDirs` and `Dry::System::Config::Namespaces` to better support programmatic construction and inspection of these configs (@timriley in #195)

### Changed

- Deprecated `Dry::System::Config::Namespaces#root` as the way to add and configure a root namespace. Use `#add_root` instead (@timriley in #195)
- Allow bootsnap plugin to use bootsnap on Ruby versions up to 3.0 (pusewicz in #196)

[Compare v0.21.0...v0.22.0](https://github.com/dry-rb/dry-system/compare/v0.21.0...v0.22.0)

## [0.21.0] - 2021-11-01


### Added

- Added **component dir namespaces** as a way to specify multiple, ordered, independent namespace rules within a given component dir. This replaces and expands upon the namespace support we previously provided via the singular `default_namespace` component dir setting (@timriley in #181)

### Changed

- `default_namespace` setting on component dirs has been deprecated. Add a component dir namespace instead, e.g. instead of:

  ```ruby
  # Inside Dry::System::Container.configure
  config.component_dirs.add "lib" do |dir|
    dir.default_namespace = "admin"
  end
  ```

  Add this:

  ```ruby
  config.component_dirs.add "lib" do |dir|
    dir.namespaces.add "admin", key: nil
  end
  ```

  (@timriley in #181)
- `Dry::System::Component#path` has been removed and replaced by `Component#require_path` and `Component#const_path` (@timriley in #181)
- Unused `Dry::System::FileNotFoundError` and `Dry::System::InvalidComponentIdentifierTypeError` errors have been removed (@timriley in #194)
- Allow bootsnap for Rubies up to 3.0.x (via #196) (@pusewicz)

[Compare v0.20.0...v0.21.0](https://github.com/dry-rb/dry-system/compare/v0.20.0...v0.21.0)

## [0.20.0] - 2021-09-12


### Fixed

- Fixed dependency graph plugin to work with internal changes introduced in 0.19.0 (@wuarmin in #173)
- Fixed behavior of `Dry::System::Identifier#start_with?` for components identified by a single segment, or if all matching segments are provided (@wuarmin in #177)
- Fixed compatibility of `finalize!` signature provided in `Container::Stubs` (@mpokrywka in #178)

### Changed

- [internal] Upgraded to new `setting` API provided in dry-configurable 0.13.0 (@timriley in #179)

[Compare v0.19.2...v0.20.0](https://github.com/dry-rb/dry-system/compare/v0.19.2...v0.20.0)

## [0.19.2] - 2021-08-30


### Changed

- [internal] Improved compatibility with upcoming dry-configurable 0.13.0 release (@timriley in #186)

[Compare v0.18.2...v0.19.2](https://github.com/dry-rb/dry-system/compare/v0.18.2...v0.19.2)

## [0.18.2] - 2021-08-30


### Changed

- [internal] Improved compatibility with upcoming dry-configurable 0.13.0 release (@timriley in #187)

[Compare v0.19.1...v0.18.2](https://github.com/dry-rb/dry-system/compare/v0.19.1...v0.18.2)

## [0.19.1] - 2021-07-11


### Fixed

- Check for registered components (@timriley in #175)


[Compare v0.19.0...v0.19.1](https://github.com/dry-rb/dry-system/compare/v0.19.0...v0.19.1)

## [0.19.0] - 2021-04-22

This release marks a huge step forward for dry-system, bringing support for Zeitwerk and other autoloaders, plus clearer configuration and improved consistency around component resolution for both finalized and lazy loading containers. [Read the announcement post](https://dry-rb.org/news/2021/04/22/dry-system-0-19-released-with-zeitwerk-support-and-more-leading-the-way-for-hanami-2-0/) for a high-level tour of the new features.

### Added

- New `component_dirs` setting on `Dry::System::Container`, which must be used for specifying the directories which dry-system will search for component source files.

  Each added component dir is relative to the container's `root`, and can have its own set of settings configured:

  ```ruby
  class MyApp::Container < Dry::System::Container
    configure do |config|
      config.root = __dir__

      # Defaults for all component dirs can be configured separately
      config.component_dirs.auto_register = true # default is already true

      # Component dirs can be added and configured independently
      config.component_dirs.add "lib" do |dir|
        dir.add_to_load_path = true # defaults to true
        dir.default_namespace = "my_app"
      end

      # All component dir settings are optional. Component dirs relying on default
      # settings can be added like so:
      config.component_dirs.add "custom_components"
    end
  end
  ```

  The following settings are available for configuring added `component_dirs`:

  - `auto_register`, a boolean, or a proc accepting a `Dry::System::Component` instance and returning a truthy or falsey value. Providing a proc allows an auto-registration policy to apply on a per-component basis
  - `add_to_load_path`, a boolean
  - `default_namespace`, a string representing the leading namespace segments to be stripped from the component's identifier (given the identifier is derived from the component's fully qualified class name)
  - `loader`, a custom replacement for the default `Dry::System::Loader` to be used for the component dir
  - `memoize`, a boolean, to enable/disable memoizing all components in the directory, or a proc accepting a `Dry::System::Component` instance and returning a truthy or falsey value. Providing a proc allows a memoization policy to apply on a per-component basis

  _All component dir settings are optional._

  (@timriley in #155, #157, and #162)
- A new autoloading-friendly `Dry::System::Loader::Autoloading` is available, which is tested to work with [Zeitwerk](https://github.com/fxn/zeitwerk) 🎉

  Configure this on the container (via a component dir `loader` setting), and the loader will no longer `require` any components, instead allowing missing constant resolution to trigger the loading of the required file.

  This loader presumes an autoloading system like Zeitwerk has already been enabled and appropriately configured.

  A recommended setup is as follows:

  ```ruby
  require "dry/system/container"
  require "dry/system/loader/autoloading"
  require "zeitwerk"

  class MyApp::Container < Dry::System::Container
    configure do |config|
      config.root = __dir__

      config.component_dirs.loader = Dry::System::Loader::Autoloading
      config.component_dirs.add_to_load_path = false

      config.component_dirs.add "lib" do |dir|
        # ...
      end
    end
  end

  loader = Zeitwerk::Loader.new
  loader.push_dir MyApp::Container.config.root.join("lib").realpath
  loader.setup
  ```

  (@timriley in #153)
- [BREAKING] `Dry::System::Component` instances (which users of dry-system will interact with via custom loaders, as well as via the `auto_register` and `memoize` component dir settings described above) now return a `Dry::System::Identifier` from their `#identifier` method. The raw identifier string may be accessed via the identifier's own `#key` or `#to_s` methods. `Identifier` also provides a helpful namespace-aware `#start_with?` method for returning whether the identifier begins with the provided namespace(s) (@timriley in #158)

### Changed

- Components with `# auto_register: false` magic comments in their source files are now properly ignored when lazy loading (@timriley in #155)
- `# memoize: true` and `# memoize: false` magic comments at top of component files are now respected (@timriley in #155)
- [BREAKING] `Dry::System::Container.load_paths!` has been renamed to `.add_to_load_path!`. This method now exists as a mere convenience only. Calling this method is no longer required for any configured `component_dirs`; these are now added to the load path automatically (@timriley in #153 and #155)
- [BREAKING] `auto_register` container setting has been removed. Configured directories to be auto-registered by adding `component_dirs` instead (@timriley in #155)
- [BREAKING] `default_namespace` container setting has been removed. Set it when adding `component_dirs` instead (@timriley in #155)
- [BREAKING] `loader` container setting has been nested under `component_dirs`, now available as `component_dirs.loader` to configure a default loader for all component dirs, as well as on individual component dirs when being added (@timriley in #162)
- [BREAKING] `Dry::System::ComponentLoadError` is no longer raised when a component could not be lazy loaded; this was only raised in a single specific failure condition. Instead, a `Dry::Container::Error` is raised in all cases of components failing to load (@timriley in #155)
- [BREAKING] `Dry::System::Container.auto_register!` has been removed. Configure `component_dirs` instead. (@timriley in #157)
- [BREAKING] The `Dry::System::Loader` interface has changed. It is now a static interface, no longer initialized with a component. The component is instead passed to each method as an argument: `.require!(component)`, `.call(component, *args)`, `.constant(component)` (@timriley in #157)
- [BREAKING] `Dry::System::Container.require_path` has been removed. Provide custom require behavior by configuring your own `loader` (@timriley in #153)

[Compare v0.18.1...v0.19.0](https://github.com/dry-rb/dry-system/compare/v0.18.1...v0.19.0)

## [0.18.1] - 2020-08-26


### Fixed

- Made `Booter#boot_files` a public method again, since it was required by dry-rails (@timriley)


[Compare v0.18.0...v0.18.1](https://github.com/dry-rb/dry-system/compare/v0.18.0...v0.18.1)

## [0.18.0] - 2020-08-24


### Added

- New `bootable_dirs` setting on `Dry::System::Container`, which accepts paths to multiple directories for looking up bootable component files. (@timriley in PR #151)

  For each entry in the `bootable_dirs` array, relative directories will be appended to the container's `root`, and absolute directories will be left unchanged.

  When searching for bootable files, the first match will win, and any subsequent same-named files will not be loaded. In this way, the `bootable_dirs` act similarly to the `$PATH` in a shell environment.


[Compare v0.17.0...v0.18.0](https://github.com/dry-rb/dry-system/compare/v0.17.0...v0.18.0)

## [0.17.0] - 2020-02-19


### Fixed

- Works with the latest dry-configurable version (issue #141) (@solnic)

### Changed

- Depends on dry-configurable `=> 0.11.1` now (@solnic)

[Compare v0.16.0...v0.17.0](https://github.com/dry-rb/dry-system/compare/v0.16.0...v0.17.0)

## [0.16.0] - 2020-02-15


### Changed

- Plugins can now define their own settings which are available in the `before(:configure)` hook (@solnic)
- Dependency on dry-configurable was bumped to `~> 0.11` (@solnic)

[Compare v0.15.0...v0.16.0](https://github.com/dry-rb/dry-system/compare/v0.15.0...v0.16.0)

## [0.15.0] - 2020-01-30


### Added

- New hook - `before(:configure)` which a plugin should use if it needs to declare new settings (@solnic)

```ruby
# in your plugin code
before(:configure) { setting :my_new_setting }

after(:configure) { config.my_new_setting = "awesome" }
```


### Changed

- Centralize error definitions in `lib/dry/system/errors.rb` (@cgeorgii)
- All built-in plugins use `before(:configure)` now to declare their settings (@solnic)

[Compare v0.14.1...v0.15.0](https://github.com/dry-rb/dry-system/compare/v0.14.1...v0.15.0)

## [0.14.1] - 2020-01-22


### Changed

- Use `Kernel.require` explicitly to avoid issues with monkey-patched `require` from ActiveSupport (@solnic)

[Compare v0.14.0...v0.14.1](https://github.com/dry-rb/dry-system/compare/v0.14.0...v0.14.1)

## [0.14.0] - 2020-01-21


### Fixed

- Misspelled plugin name raises meaningful error (issue #132) (@cgeorgii)
- Fail fast if auto_registrar config contains incorrect path (@cutalion)


[Compare v0.13.2...v0.14.0](https://github.com/dry-rb/dry-system/compare/v0.13.2...v0.14.0)

## [0.13.2] - 2019-12-28


### Fixed

- More keyword warnings (flash-gordon)


[Compare v0.13.1...v0.13.2](https://github.com/dry-rb/dry-system/compare/v0.13.1...v0.13.2)

## [0.13.1] - 2019-11-07


### Fixed

- Fixed keyword warnings reported by Ruby 2.7 (flash-gordon)
- Duplicates in `Dry::System::Plugins.loaded_dependencies` (AMHOL)


[Compare v0.13.0...v0.13.1](https://github.com/dry-rb/dry-system/compare/v0.13.0...v0.13.1)

## [0.13.0] - 2019-10-13


### Added

- `Container.resolve` accepts and optional block parameter which will be called if component cannot be found. This makes dry-system consistent with dry-container 0.7.2 (flash-gordon)
  ```ruby
  App.resolve('missing.dep') { :fallback } # => :fallback
  ```

### Changed

- [BREAKING] `Container.key?` triggers lazy-loading for not finalized containers. If component wasn't found it returns `false` without raising an error. This is a breaking change, if you seek the previous behavior, use `Container.registered?` (flash-gordon)

[Compare v0.12.0...v0.13.0](https://github.com/dry-rb/dry-system/compare/v0.12.0...v0.13.0)

## [0.12.0] - 2019-04-24


### Changed

- Compatibility with dry-struct 1.0 and dry-types 1.0 (flash-gordon)

[Compare v0.11.0...v0.12.0](https://github.com/dry-rb/dry-system/compare/v0.11.0...v0.12.0)

## [0.11.0] - 2019-03-22


### Changed

- [BREAKING] `:decorate` plugin was moved from dry-system to dry-container (available in 0.7.0+). To upgrade remove `use :decorate` and change `decorate` calls from `decorate(key, decorator: something)` to `decorate(key, with: something)` (flash-gordon)
- [internal] Compatibility with dry-struct 0.7.0 and dry-types 0.15.0

[Compare v0.10.1...v0.11.0](https://github.com/dry-rb/dry-system/compare/v0.10.1...v0.11.0)

## [0.10.1] - 2018-07-05


### Added

- Support for stopping bootable components with `Container.stop(component_name)` (GustavoCaso)

### Fixed

- When using a non-finalized container, you can now resolve multiple different container objects registered using the same root key as a bootable component (timriley)


[Compare v0.10.0...v0.10.1](https://github.com/dry-rb/dry-system/compare/v0.10.0...v0.10.1)

## [0.10.0] - 2018-06-07


### Added

- You can now set a custom inflector on the container level. As a result, the `Loader`'s constructor accepts two arguments: `path` and `inflector`, update your custom loaders accordingly (flash-gordon)

  ```ruby
  class MyContainer < Dry::System::Container
    configure do |config|
      config.inflector = Dry::Inflector.new do |inflections|
        inflections.acronym('API')
      end
    end
  end
  ```

### Changed

- A helpful error will be raised if an invalid setting value is provided (GustavoCaso)
- When using setting plugin, will use default values from types (GustavoCaso)
- Minimal supported ruby version was bumped to `2.3` (flash-gordon)
- `dry-struct` was updated to `~> 0.5` (flash-gordon)

[Compare v0.9.2...v0.10.0](https://github.com/dry-rb/dry-system/compare/v0.9.2...v0.10.0)

## [0.9.2] - 2018-02-08


### Fixed

- Default namespace no longer breaks resolving dependencies with identifier that includes part of the namespace (ie `mail.mailer`) (GustavoCaso)


[Compare v0.9.1...v0.9.2](https://github.com/dry-rb/dry-system/compare/v0.9.1...v0.9.2)

## [0.9.1] - 2018-01-03


### Fixed

- Plugin dependencies are now auto-required and a meaningful error is raised when a dep failed to load (solnic)


[Compare v0.9.0...v0.9.1](https://github.com/dry-rb/dry-system/compare/v0.9.0...v0.9.1)

## [0.9.0] - 2018-01-02


### Added

- Plugin API (solnic)
- `:env` plugin which adds support for setting `env` config value (solnic)
- `:logging` plugin which adds a default logger (solnic)
- `:decorate` plugin for decorating registered objects (solnic)
- `:notifications` plugin adding pub/sub bus to containers (solnic)
- `:monitoring` plugin which adds `monitor` method for monitoring object method calls (solnic)
- `:bootsnap` plugin which adds support for bootsnap (solnic)

### Changed

- [BREAKING] renamed `Container.{require=>require_from_root}` (GustavoCaso)

[Compare v0.8.1...v0.9.0](https://github.com/dry-rb/dry-system/compare/v0.8.1...v0.9.0)

## [0.8.1] - 2017-10-17


### Fixed

- Aliasing an external component works correctly (solnic)
- Manually calling `:init` will also finalize a component (solnic)


[Compare v0.8.0...v0.8.1](https://github.com/dry-rb/dry-system/compare/v0.8.0...v0.8.1)

## [0.8.0] - 2017-10-16


### Added

- Support for external bootable components (solnic)
- Built-in `:system` components including `:settings` component (solnic)

### Fixed

- Lazy-loading components work when a container has `default_namespace` configured (GustavoCaso)

### Changed

- [BREAKING] Improved boot DSL with support for namespacing and lifecycle before/after callbacks (solnic)

[Compare v0.7.3...v0.8.0](https://github.com/dry-rb/dry-system/compare/v0.7.3...v0.8.0)

## [0.7.3] - 2017-08-02


### Fixed

- `Container.enable_stubs!` calls super too, which actually adds `stub` API (solnic)
- Issues with lazy-loading and import in stub mode are gone (solnic)


[Compare v0.7.2...v0.7.3](https://github.com/dry-rb/dry-system/compare/v0.7.2...v0.7.3)

## [0.7.2] - 2017-08-02


### Added

- `Container.enable_stubs!` for test environments which enables stubbing components (GustavoCaso)

### Changed

- Component identifiers can now include same name more than once ie `foo.stuff.foo` (GustavoCaso)
- `Container#boot!` was renamed to `Container#start` (davydovanton)
- `Container#boot` was renamed to `Container#init` (davydovanton)

[Compare v0.7.1...v0.7.2](https://github.com/dry-rb/dry-system/compare/v0.7.1...v0.7.2)

## [0.7.1] - 2017-06-16


### Changed

- Accept string values for Container's `root` config (timriley)

[Compare v0.7.0...v0.7.1](https://github.com/dry-rb/dry-system/compare/v0.7.0...v0.7.1)

## [0.7.0] - 2017-06-15


### Added

- Added `manual_registrar` container setting (along with default `ManualRegistrar` implementation), and `registrations_dir` setting. These provide support for a well-established place for keeping files with manual container registrations (timriley)
- AutoRegistrar parses initial lines of Ruby source files for "magic comments" when auto-registering components. An `# auto_register: false` magic comment will prevent a Ruby file from being auto-registered (timriley)
- `Container.auto_register!`, when called with a block, yields a configuration object to control the auto-registration behavior for that path, with support for configuring 2 different aspects of auto-registration behavior (both optional):

  ```ruby
  class MyContainer < Dry::System::Container
    auto_register!('lib') do |config|
      config.instance do |component|
        # custom logic for initializing a component
      end

      config.exclude do |component|
        # return true to skip auto-registration of the component, e.g.
        # component.path =~ /entities/
      end
    end
  end
  ```
- A helpful error will be raised if a bootable component's finalize block name doesn't match its boot file name (GustavoCaso)

### Changed

- The `default_namespace` container setting now supports multi-level namespaces (GustavoCaso)
- `Container.auto_register!` yields a configuration block instead of a block for returning a custom instance (see above) (GustavoCaso)
- `Container.import` now requires an explicit local name for the imported container (e.g. `import(local_name: AnotherContainer)`) (timriley)

[Compare v0.6.0...v0.7.0](https://github.com/dry-rb/dry-system/compare/v0.6.0...v0.7.0)

## [0.6.0] - 2016-02-02


### Changed

- Lazy load components as they are resolved, rather than on injection (timriley)
- Perform registration even though component already required (blelump)

[Compare v0.5.1...v0.6.0](https://github.com/dry-rb/dry-system/compare/v0.5.1...v0.6.0)

## [0.5.1] - 2016-08-23


### Fixed

- Undefined locals or method calls will raise proper exceptions in Lifecycle DSL (aradunovic)


[Compare v0.5.0...v0.5.1](https://github.com/dry-rb/dry-system/compare/v0.5.0...v0.5.1)

## [0.5.0] - 2016-08-15

for multi-container setups. As part of this release `dry-system` has been renamed to `dry-system`.

### Added

- Boot DSL with:
  - Lifecycle triggers: `init`, `start` and `stop` (solnic)
  - `use` method which auto-boots a dependency and makes it available in the booting context (solnic)
- When a component relies on a bootable component, and is being loaded in isolation, the component will be booted automatically (solnic)

### Changed

- [BREAKING] `Dry::Component::Container` is now `Dry::System::Container` (solnic)
- [BREAKING] Configurable `loader` is now a class that accepts container's config and responds to `#constant` and `#instance` (solnic)
- [BREAKING] `core_dir` renameda to `system_dir` and defaults to `system` (solnic)
- [BREAKING] `auto_register!` yields `Component` objects (solnic)

[Compare v0.4.3...v0.5.0](https://github.com/dry-rb/dry-system/compare/v0.4.3...v0.5.0)

## [0.4.3] - 2016-08-01


### Fixed

- Return immediately from `Container.load_component` if the requested component key already exists in the container. This fixes a crash when requesting to load a manually registered component with a name that doesn't map to a filename (timriley in [#24](https://github.com/dry-rb/dry-system/pull/24))


[Compare v0.4.2...v0.4.3](https://github.com/dry-rb/dry-system/compare/v0.4.2...v0.4.3)

## [0.4.2] - 2016-07-26


### Fixed

- Ensure file components can be loaded when they're requested for the first time using their shorthand container identifier (i.e. with the container's default namespace removed) (timriley)


[Compare v0.4.1...v0.4.2](https://github.com/dry-rb/dry-system/compare/v0.4.1...v0.4.2)

## [0.4.1] - 2016-07-26


### Fixed

- Require the 0.4.0 release of dry-auto_inject for the features below (in 0.4.0) to work properly (timriley)


[Compare v0.4.0...v0.4.1](https://github.com/dry-rb/dry-system/compare/v0.4.0...v0.4.1)

## [0.4.0] - 2016-07-26


### Added

- Support for supplying a default namespace to a container, which is passed to the container's injector to allow for convenient shorthand access to registered objects in the same namespace (timriley in [#20](https://github.com/dry-rb/dry-system/pull/20))

  ```ruby
  # Set up container with default namespace
  module Admin
    class Container < Dry::Component::Container
      configure do |config|
        config.root = Pathname.new(__dir__).join("../..")
        config.default_namespace = "admin"
      end
    end

    Import = Container.injector
  end

  module Admin
    class CreateUser
      # "users.repository" will resolve an Admin::Users::Repository instance,
      # where previously you had to identify it as "admin.users.repository"
      include Admin::Import["users.repository"]
    end
  end
  ```
- Support for supplying to options directly to dry-auto_inject's `Builder` via `Dry::Component::Container#injector(options)`. This allows you to provide dry-auto_inject customizations like your own container of injection strategies (timriley in [#20](https://github.com/dry-rb/dry-system/pull/20))
- Support for accessing all available injector strategies, not just the defaults (e.g. `MyContainer.injector.some_custom_strategy`) (timriley in [#19](https://github.com/dry-rb/dry-system/pull/19))

### Changed

- Subclasses of `Dry::Component::Container` no longer have an `Injector` constant automatically defined within them. The recommended approach is to save your own injector object to a constant, which allows you to pass options to it at the same time, e.g. `MyApp::Import = MyApp::Container.injector(my_options)` (timriley in [#19](https://github.com/dry-rb/dry-system/pull/19))

[Compare v0.3.0...v0.4.0](https://github.com/dry-rb/dry-system/compare/v0.3.0...v0.4.0)

## [0.3.0] - 2016-06-18

Removed two pieces that are moving to dry-web:

### Changed

- Removed two pieces that are moving to dry-web:
- Removed `env` setting from `Container` (timriley)
- Removed `Dry::Component::Config` and `options` setting from `Container` (timriley)
- Changed `Component#configure` behavior so it can be run multiple times for configuration to be applied in multiple passes (timriley)

[Compare v0.2.0...v0.3.0](https://github.com/dry-rb/dry-system/compare/v0.2.0...v0.3.0)

## [0.2.0] - 2016-06-13


### Fixed

- Fixed bug where specified auto-inject strategies were not respected (timriley)

### Changed

- Component core directory is now `component/` by default (timriley)
- Injector default stragegy is now whatever dry-auto_inject's default is (rather than hard-coding a particular default strategy for dry-system) (timriley)

[Compare v0.1.0...v0.2.0](https://github.com/dry-rb/dry-system/compare/v0.1.0...v0.2.0)

## [0.1.0] - 2016-06-07


### Added

- Provide a dependency injector as an `Inject` constant inside any subclass of `Dry::Component::Container`. This injector supports all of `dry-auto_inject`'s default injection strategies, and will lazily load any dependencies as they are injected. It also supports arbitrarily switching strategies, so they can be used in different classes as required (e.g. `include MyComponent::Inject.args["dep"]`) (timriley)
- Support aliased dependency names when calling the injector object (e.g. `MyComponent::Inject[foo: "my_app.foo", bar: "another.thing"]`) (timriley)
- Allow a custom dependency loader to be set on a container via its config (AMHOL)

  ```ruby
  class MyContainer < Dry::Component::Container
    configure do |config|
      # other config
      config.loader = MyLoader
    end
  end
  ```

### Changed

- `Container.boot` now only makes a simple `require` for the boot file (solnic)
- Container object is passed to `Container.finalize` blocks (solnic)
- Allow `Pathname` objects passed to `Container.require` (solnic)
- Support lazily loading missing dependencies from imported containers (solnic)
- `Container.import_module` renamed to `.injector` (timriley)
- Default injection strategy is now `kwargs`, courtesy of the new dry-auto_inject default (timriley)

[Compare v0.0.2...v0.1.0](https://github.com/dry-rb/dry-system/compare/v0.0.2...v0.1.0)

## [0.0.2] - 2015-12-24


### Added

- Containers have a `name` setting (solnic)
- Containers can be imported into one another (solnic)

### Changed

- Container name is used to determine the name of its config file (solnic)

[Compare v0.0.1...v0.0.2](https://github.com/dry-rb/dry-system/compare/v0.0.1...v0.0.2)

## [0.0.1] - 2015-12-24

First public release, extracted from rodakase project
