# rspec-openapi

Generate OpenAPI specs from RSpec request specs.

## What's this?

There are some gems which generate OpenAPI specs from RSpec request specs.
However, they require a special DSL specific to these gems, and we can't reuse existing request specs as they are.

Unlike such [existing gems](#links), rspec-openapi can generate OpenAPI specs from request specs without requiring any special DSL.
Furthermore, rspec-openapi keeps manual modifications when it merges automated changes to OpenAPI specs
in case we can't generate everything from request specs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-openapi', group: :test
```

## Usage

Run rspec with OPENAPI=1 to generate `doc/openapi.yaml` for your request specs.

```bash
$ OPENAPI=1 rspec
```

### Example

```rb
# TODO
```

### Configuration

If you want to change the path to generate a spec from `doc/openapi.yaml`, use:

```rb
RSpec::OpenAPI.path = 'doc/schema.yaml'
```

### How can I add information which can't be generated from RSpec?

rspec-openapi tries to keep manual modifications as much as possible when generating specs.
You can directly edit `doc/openapi.yaml` as you like without spoiling the automatic generation capability.

### Can I exclude specific specs from OpenAPI generation?

Yes, you can specify `openapi: false` to disable the automatic generation.

```rb
RSpec.describe '/resources', type: :request, openapi: false do
  # ...
end

# or

RSpec.describe '/resources', type: :request do
  it 'returns a resource', openapi: false do
    # ...
  end
end
```

## Project status

PoC / Experimental

This worked for some of my Rails apps, but this may raise a basic error for your app.

### TODO

1. Show query, request params
2. Write README

### Current limitations

* This only works for RSpec request specs
* Only Rails is supported for looking up a request route

### Other missing features with notes

* Delete obsoleted endpoints
  * Give up, or at least make the feature optional?
  * Running all to detect obsoleted endpoints is sometimes not realistic anyway.
* Intelligent merges
  * To maintain both automated changes and manual edits, the schema merge needs to be intelligent.
  * We'll just deep-reverse-merge schema for now, but if there's a $ref for example, modifications
    there should be rerouted to the referenced object.
  * A type could be an array of all possible types when merged.

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
