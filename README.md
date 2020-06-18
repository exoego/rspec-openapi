# rspec-openapi

Generate OpenAPI specs from RSpec request specs.

## What's this?

There are some gems which generate OpenAPI specs from RSpec request specs.
However, they require a special DSL specific to these gems, and we can't reuse existing request specs as they are.

Unlike such [existing gems](#links), rspec-openapi can generate OpenAPI specs by just adding `:openapi` tag
without rewriting your actual test code.
Furthermore, rspec-openapi allows manual edits while allowing automatic generation, in case we can't generate
every information from request specs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-openapi', group: :test
```

## Usage

Run rspec with OPENAPI=1 to generate `doc/openapi.yaml` for your request specs tagged with `:openapi`.

```bash
$ OPENAPI=1 rspec
```

### Example

```rb
# TODO
```

### Configuration

If you want to change the path to generate a spec from `doc/openapi.yaml`,

```rb
# TODO
```

### How can I add information which can't be generated from RSpec?

rspec-openapi tries to keep manual modifications as much as possible when generating specs.
You can directly edit `doc/openapi.yaml` as you like without spoiling the automatic generation capability.

## TODO

1. Detect routed path from method / path (Rails-specific)
2. Get request params
3. Reducing the amount of Resource class duplications: Especially cursor-based pagination? (requires manual edit?)
4. Represent a list of resources properly (do we need type merge from the beginning, or just pick the first element?)
5. Support nested object
6. Change error response's recource class
7. Do something for nil (nullable)

## Design notes about missing features

* Delete obsoleted endpoints
  * Give up, or at least make the feature optional?
  * Running all to detect obsoleted endpoints is sometimes not realistic anyway.
* Guess "required" and "non-nullable"
  * required → optional, non-nullable → nullable are obvious merges.
  * But is it reasonable to generate required and non-nullable automatically,
    often from a single spec? Should we leave it for manual changes?
* Intelligent merges
  * To maintain both automated changes and manual edits, the schema merge needs to be intelligent.
  * We'll just deep-merge schema for now, but if a resource class is renamed, maybe merges should
    be rerouted to the renamed class.

## Links

Existing RSpec plugins which have OpenAPI integration:

* [zipmark/rspec\_api\_documentation](https://github.com/zipmark/rspec_api_documentation)
* [rswag/rswag](https://github.com/rswag/rswag)
* [drewish/rspec-rails-swagger](https://github.com/drewish/rspec-rails-swagger)

## Acknowledgements

This gem was heavily inspired by the following gem:

* [r7kamura/autodoc](https://github.com/r7kamura/autodoc)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
