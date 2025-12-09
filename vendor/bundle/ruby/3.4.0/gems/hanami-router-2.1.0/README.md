# Hanami::Router

Rack compatible, lightweight and fast HTTP Router for Ruby and [Hanami](http://hanamirb.org).

## Version

**This branch contains the code for `hanami-router` 2.x.**

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-router.svg)](https://badge.fury.io/rb/hanami-router)
[![CI](https://github.com/hanami/router/workflows/ci/badge.svg?branch=main)](https://github.com/hanami/router/actions?query=workflow%3Aci+branch%3Amain)
[![Test Coverage](https://codecov.io/gh/hanami/router/branch/main/graph/badge.svg)](https://codecov.io/gh/hanami/router)
[![Depfu](https://badges.depfu.com/badges/5f6b8e8fa3b0d082539f0b0f84d55960/overview.svg)](https://depfu.com/github/hanami/router?project=Bundler)
[![Inline Docs](http://inch-ci.org/github/hanami/router.svg)](http://inch-ci.org/github/hanami/router)

## Contact

* Home page: http://hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-router
* Bugs/Issues: https://github.com/hanami/router/issues
* Support: http://stackoverflow.com/questions/tagged/hanami
* Chat: http://chat.hanamirb.org

## Rubies

__Hanami::Router__ supports Ruby (MRI) 3.0+


## Installation

Add this line to your application's Gemfile:

```ruby
gem "hanami-router"
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install hanami-router
```

## Getting Started

Create a file named `config.ru`

```ruby
# frozen_string_literal: true
require "hanami/router"

app = Hanami::Router.new do
  get "/", to: ->(env) { [200, {}, ["Welcome to Hanami!"]] }
end

run app
```

From the shell:

```shell
$ bundle exec rackup
```

## Usage

__Hanami::Router__ is designed to work as a standalone framework or within a
context of a [Hanami](http://hanamirb.org) application.

For the standalone usage, it supports neat features:

### A Beautiful DSL:

```ruby
Hanami::Router.new do
  root                to: ->(env) { [200, {}, ["Hello"]] }
  get "/lambda",      to: ->(env) { [200, {}, ["World"]] }
  get "/dashboard",   to: Dashboard::Index
  get "/rack-app",    to: RackApp.new

  redirect "/legacy", to: "/"

  mount Api::App, at: "/api"

  scope "admin" do
    get "/users", to: Users::Index
  end
end
```

### Fixed string matching:

```ruby
Hanami::Router.new do
  get "/hanami", to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
end
```

### String matching with variables:

```ruby
Hanami::Router.new do
  get "/flowers/:id", to: ->(env) { [200, {}, ["Hello from Flower no. #{ env["router.params"][:id] }!"]] }
end
```

### Variables Constraints:

```ruby
Hanami::Router.new do
  get "/flowers/:id", id: /\d+/, to: ->(env) { [200, {}, [":id must be a number!"]] }
end
```

### String matching with globbing:

```ruby
Hanami::Router.new do
  get "/*match", to: ->(env) { [200, {}, ["This is catch all: #{ env["router.params"].inspect }!"]] }
end
```

### String matching with optional tokens:

```ruby
Hanami::Router.new do
  get "/hanami(.:format)" to: ->(env) { [200, {}, ["You"ve requested #{ env["router.params"][:format] }!"]] }
end
```

### Support for the most common HTTP methods:

```ruby
endpoint = ->(env) { [200, {}, ["Hello from Hanami!"]] }

Hanami::Router.new do
  get     "/hanami", to: endpoint
  post    "/hanami", to: endpoint
  put     "/hanami", to: endpoint
  patch   "/hanami", to: endpoint
  delete  "/hanami", to: endpoint
  trace   "/hanami", to: endpoint
  options "/hanami", to: endpoint
end
```

### Root:

```ruby
Hanami::Router.new do
  root to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
end
```

### Redirect:

```ruby
Hanami::Router.new do
  get "/redirect_destination", to: ->(env) { [200, {}, ["Redirect destination!"]] }
  redirect "/legacy",          to: "/redirect_destination"
end
```

### Named routes:

```ruby
router = Hanami::Router.new(scheme: "https", host: "hanamirb.org") do
  get "/hanami", to: ->(env) { [200, {}, ["Hello from Hanami!"]] }, as: :hanami
end

router.path(:hanami) # => "/hanami"
router.url(:hanami)  # => "https://hanamirb.org/hanami"
```


### Scopes:

```ruby
router = Hanami::Router.new do
  scope "animals" do
    scope "mammals" do
      get "/cats", to: ->(env) { [200, {}, ["Meow!"]] }, as: :cats
    end
  end
end

# and it generates:

router.path(:animals_mammals_cats) # => "/animals/mammals/cats"
```



### Mount Rack applications:

Mounting a Rack application will forward all kind of HTTP requests to the app,
when the request path matches the `at:` path.

```ruby
Hanami::Router.new do
  mount MyRackApp.new, at: "/foo"
end
```

### Duck typed endpoints:

Everything that responds to `#call` is invoked as it is:

```ruby
Hanami::Router.new do
  get "/hanami",     to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
  get "/rack-app",   to: RackApp.new
  get "/method",     to: ActionControllerSubclass.action(:new)
end
```

### Implicit Not Found (404):

```ruby
router = Hanami::Router.new
router.call(Rack::MockRequest.env_for("/unknown")).status # => 404
```

### Explicit Not Found:

```ruby
router = Hanami::Router.new(not_found: ->(_) { [499, {}, []]})
router.call(Rack::MockRequest.env_for("/unknown")).status # => 499
```

### Body Parsers

Rack ignores request bodies unless they come from a form submission.
If we have a JSON endpoint, the payload isn't available in the params hash:

```ruby
Rack::Request.new(env).params # => {}
```

This feature enables body parsing for specific MIME Types.
It comes with a built-in JSON parser and allows to pass custom parsers.

#### JSON Parsing

```ruby
# frozen_string_literal: true

require "hanami/router"
require "hanami/middleware/body_parser"

app = Hanami::Router.new do
  patch "/books/:id", to: ->(env) { [200, {}, [env["router.params"].inspect]] }
end

use Hanami::Middleware::BodyParser, :json
run app
```

```shell
curl http://localhost:2300/books/1    \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"       \
  -d '{"published":"true"}'           \
  -X PATCH

# => [200, {}, ["{:published=>\"true\",:id=>\"1\"}"]]
```

If the json can't be parsed an exception is raised:

```ruby
Hanami::Middleware::BodyParser::BodyParsingError
```

##### `multi_json`

If you want to use a different JSON backend, include `multi_json` in your `Gemfile`.

#### Custom Parsers

```ruby
# frozen_string_literal: true

require "hanami/router"
require "hanami/middleware/body_parser"

# See Hanami::Middleware::BodyParser::Parser
class XmlParser < Hanami::Middleware::BodyParser::Parser
  def mime_types
    ["application/xml", "text/xml"]
  end

  # Parse body and return a Hash
  def parse(body)
    # parse xml
  rescue SomeXmlParsingError => e
    raise Hanami::Middleware::BodyParser::BodyParsingError.new(e)
  end
end

app = Hanami::Router.new do
  patch "/authors/:id", to: ->(env) { [200, {}, [env["router.params"].inspect]] }
end

use Hanami::Middleware::BodyParser, XmlParser
run app
```

```shell
curl http://localhost:2300/authors/1 \
  -H "Content-Type: application/xml" \
  -H "Accept: application/xml"       \
  -d '<name>LG</name>'               \
  -X PATCH

# => [200, {}, ["{:name=>\"LG\",:id=>\"1\"}"]]
```

## Testing

```ruby
# frozen_string_literal: true

require "hanami/router"

router = Hanami::Router.new do
  get "/books/:id", to: "books.show", as: :book
end

route = router.recognize("/books/23")
route.verb      # "GET"
route.endpoint  # => "books.show"
route.params    # => {:id=>"23"}
route.routable? # => true

route = router.recognize(:book, id: 23)
route.verb      # "GET"
route.endpoint  # => "books.show"
route.params    # => {:id=>"23"}
route.routable? # => true

route = router.recognize("/books/23", {}, method: :post)
route.verb      # "POST"
route.routable? # => false
```

## Versioning

__Hanami::Router__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014 Hanami Team – Released under MIT License
