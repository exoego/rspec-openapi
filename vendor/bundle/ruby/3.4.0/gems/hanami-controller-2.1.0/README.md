# Hanami::Controller

Complete, fast and testable actions for Rack and [Hanami](http://hanamirb.org)

## Version

**This branch contains the code for `hanami-controller` 2.x.**

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-controller.svg)](https://badge.fury.io/rb/hanami-controller)
[![CI](https://github.com/hanami/controller/workflows/ci/badge.svg?branch=main)](https://github.com/hanami/controller/actions?query=workflow%3Aci+branch%3Amain)
[![Test Coverage](https://codecov.io/gh/hanami/controller/branch/main/graph/badge.svg)](https://codecov.io/gh/hanami/controller)
[![Depfu](https://badges.depfu.com/badges/7cd17419fba78b726be1353118fb01de/overview.svg)](https://depfu.com/github/hanami/controller?project=Bundler)
[![Inline Docs](http://inch-ci.org/github/hanami/controller.svg)](http://inch-ci.org/github/hanami/controller)

## Contact

* Home page: http://hanamirb.org
* Community: http://hanamirb.org/community
* Guides: https://guides.hanamirb.org
* Mailing List: http://hanamirb.org/mailing-list
* API Doc: http://rdoc.info/gems/hanami-controller
* Bugs/Issues: https://github.com/hanami/controller/issues
* Chat: http://chat.hanamirb.org

## Rubies

__Hanami::Controller__ supports Ruby (MRI) 3.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hanami-controller"
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install hanami-controller
```

## Usage

Hanami::Controller is a micro library for web frameworks.
It works beautifully with [Hanami::Router](https://github.com/hanami/router), but it can be employed everywhere.
It's designed to be fast and testable.

### Actions

The core of this framework are the actions.
They are the endpoints that respond to incoming HTTP requests.

```ruby
class Show < Hanami::Action
  def handle(req, res)
    res[:article] = ArticleRepository.new.find(req.params[:id])
  end
end
```

`Hanami::Action` follows the Hanami philosophy: a single purpose object with a minimal interface.

In this case, `Hanami::Action` provides the key public interface of `#call(env)`, making your actions Rack-compatible.
To provide custom behaviour when your actions are being called, you can implement `#handle(req, res)`

**An action is an object** and **you have full control over it**.
In other words, you have the freedom to instantiate, inject dependencies and test it, both at the unit and integration level.

In the example below, the default repository is `ArticleRepository`. During a unit test we can inject a stubbed version, and invoke `#call` with the params.
__We're avoiding HTTP calls__, we're also going to avoid hitting the database (it depends on the stubbed repository), __we're just dealing with message passing__.
Imagine how **fast** the unit test could be.

```ruby
class Show < Hanami::Action
  def initialize(configuration:, repository: ArticleRepository.new)
    @repository = repository
    super(configuration: configuration)
  end

  def handle(req, res)
    res[:article] = repository.find(req.params[:id])
  end

  private

  attr_reader :repository
end

configuration = Hanami::Controller::Configuration.new
action = Show.new(configuration: configuration, repository: ArticleRepository.new)
action.call(id: 23)
```

### Params

The request params are part of the request passed as an argument to the `#handle` method.
If routed with *Hanami::Router*, it extracts the relevant bits from the Rack `env` (eg the requested `:id`).
Otherwise everything is passed as is: the full Rack `env` in production, and the given `Hash` for unit tests.

With `Hanami::Router`:

```ruby
class Show < Hanami::Action
  def handle(req, *)
    # ...
    puts req.params # => { id: 23 } extracted from Rack env
  end
end
```

Standalone:

```ruby
class Show < Hanami::Action
  def handle(req, *)
    # ...
    puts req.params # => { :"rack.version"=>[1, 2], :"rack.input"=>#<StringIO:0x007fa563463948>, ... }
  end
end
```

Unit Testing:

```ruby
class Show < Hanami::Action
  def handle(req, *)
    # ...
    puts req.params # => { id: 23, key: "value" } passed as it is from testing
  end
end

action   = Show.new(configuration: configuration)
response = action.call(id: 23, key: "value")
```

#### Whitelisting

Params represent an untrusted input.
For security reasons it's recommended to whitelist them.

```ruby
require "hanami/validations"
require "hanami/controller"

class Signup < Hanami::Action
  params do
    required(:first_name).filled(:str?)
    required(:last_name).filled(:str?)
    required(:email).filled(:str?)

    required(:address).schema do
      required(:line_one).filled(:str?)
      required(:state).filled(:str?)
      required(:country).filled(:str?)
    end
  end

  def handle(req, *)
    # Describe inheritance hierarchy
    puts req.params.class            # => Signup::Params
    puts req.params.class.superclass # => Hanami::Action::Params

    # Whitelist :first_name, but not :admin
    puts req.params[:first_name]     # => "Luca"
    puts req.params[:admin]          # => nil

    # Whitelist nested params [:address][:line_one], not [:address][:line_two]
    puts req.params[:address][:line_one] # => "69 Tender St"
    puts req.params[:address][:line_two] # => nil
  end
end
```

#### Validations & Coercions

Because params are a well defined set of data required to fulfill a feature
in your application, you can validate them. So you can avoid hitting lower MVC layers
when params are invalid.

If you specify the `:type` option, the param will be coerced.

```ruby
require "hanami/validations"
require "hanami/controller"

class Signup < Hanami::Action
  MEGABYTE = 1024 ** 2

  params do
    required(:first_name).filled(:str?)
    required(:last_name).filled(:str?)
    required(:email).filled?(:str?, format?: /\A.+@.+\z/)
    required(:password).filled(:str?).confirmation
    required(:terms_of_service).filled(:bool?)
    required(:age).filled(:int?, included_in?: 18..99)
    optional(:avatar).filled(size?: 1..(MEGABYTE * 3))
  end

  def handle(req, *)
    halt 400 unless req.params.valid?
    # ...
  end
end
```

### Response

The output of `#call` is a `Hanami::Action::Response`:

```ruby
class Show < Hanami::Action
end

action = Show.new(configuration: configuration)
action.call({}) # => #<Hanami::Action::Response:0x00007fe8be968418 @status=200 ...>
```

This is the same `res` response object passed to `#handle`, where you can use its accessors to explicitly set status, headers, and body:

```ruby
class Show < Hanami::Action
  def handle(*, res)
    res.status  = 201
    res.body    = "Hi!"
    res.headers.merge!("X-Custom" => "OK")
  end
end

action = Show.new
action.call({}) # => [201, { "X-Custom" => "OK" }, ["Hi!"]]
```

### Exposures

In case you need to send data from the action to other layers of your application, you can use exposures.
By default, an action exposes the received params.

```ruby
class Show < Hanami::Action
  def handle(req, res)
    res[:article] = ArticleRepository.new.find(req.params[:id])
  end
end

action   = Show.new(configuration: configuration)
response = action.call(id: 23)

article = response[:article]
article.class # => Article
article.id # => 23

response.exposures.keys # => [:params, :article]
```

### Callbacks

If you need to execute logic **before** or **after** `#handle` is invoked, you can use _callbacks_.
They are useful for shared logic like authentication checks.

```ruby
class Show < Hanami::Action
  before :authenticate, :set_article

  def handle(*)
  end

  private

  def authenticate
    # ...
  end

  # `req` and `res` in the method signature is optional
  def set_article(req, res)
    res[:article] = ArticleRepository.new.find(req.params[:id])
  end
end
```

Callbacks can also be expressed as anonymous lambdas:

```ruby
class Show < Hanami::Action
  before { ... } # do some authentication stuff
  before { |req, res| res[:article] = ArticleRepository.new.find(req.params[:id]) }

  def handle(*)
  end
end
```

### Exceptions management

When the app raises an exception, `hanami-controller`, does **NOT** manage it.
You can write custom exception handling on per action or configuration basis.

An exception handler can be a valid HTTP status code (eg. `500`, `401`), or a `Symbol` that represents an action method.

```ruby
class Show < Hanami::Action
  handle_exception StandardError => 500

  def handle(*)
    raise
  end
end

action = Show.new(configuration: configuration)
action.call({}) # => [500, {}, ["Internal Server Error"]]
```

You can map a specific raised exception to a different HTTP status.

```ruby
class Show < Hanami::Action
  handle_exception RecordNotFound => 404

  def handle(*)
    raise RecordNotFound
  end
end

action = Show.new(configuration: configuration)
action.call({}) # => [404, {}, ["Not Found"]]
```

You can also define custom handlers for exceptions.

```ruby
class Create < Hanami::Action
  handle_exception ArgumentError => :my_custom_handler

  gle(*)
    raise ArgumentError.new("Invalid arguments")
  end

  private

  def my_custom_handler(req, res, exception)
    res.status = 400
    res.body   = exception.message
  end
end

action = Create.new(configuration: configuration)
action.call({}) # => [400, {}, ["Invalid arguments"]]
```

Exception policies can be defined globally via configuration:

```ruby
configuration = Hanami::Controller::Configuration.new do |config|
  config.handle_exception RecordNotFound => 404
end

class Show < Hanami::Action
  def handle(*)
    raise RecordNotFound
  end
end

action = Show.new(configuration: configuration)
action.call({}) # => [404, {}, ["Not Found"]]
```

#### Inherited Exceptions

```ruby
class MyCustomException < StandardError
end

module Articles
  class Index < Hanami::Action
    handle_exception MyCustomException => :handle_my_exception

    def handle(*)
      raise MyCustomException
    end

    private

    def handle_my_exception(req, res, exception)
      # ...
    end
  end

  class Show < Hanami::Action
    handle_exception StandardError => :handle_standard_error

    def handle(*)
      raise MyCustomException
    end

    private

    def handle_standard_error(req, res, exception)
      # ...
    end
  end
end

Articles::Index.new.call({}) # => `handle_my_exception` will be invoked
Articles::Show.new.call({})  # => `handle_standard_error` will be invoked,
                             #   because `MyCustomException` inherits from `StandardError`
```

### Throwable HTTP statuses

When `#halt` is used with a valid HTTP code, it stops the execution and sets the proper status and body for the response:

```ruby
class Show < Hanami::Action
  before :authenticate!

  def handle(*)
    # ...
  end

  private

  def authenticate!
    halt 401 unless authenticated?
  end
end

action = Show.new(configuration: configuration)
action.call({}) # => [401, {}, ["Unauthorized"]]
```

Alternatively, you can specify a custom message.

```ruby
class Show < Hanami::Action
  def handle(req, res)
    res[:droid] = DroidRepository.new.find(req.params[:id]) or not_found
  end

  private

  def not_found
    halt 404, "This is not the droid you're looking for"
  end
end

action = Show.new(configuration: configuration)
action.call({}) # => [404, {}, ["This is not the droid you're looking for"]]
```

### Cookies

You can read the original cookies sent from the HTTP client via `req.cookies`.
If you want to send cookies in the response, use `res.cookies`.

They are read as a Hash from Rack env:

```ruby
require "hanami/controller"
require "hanami/action/cookies"

class ReadCookiesFromRackEnv < Hanami::Action
  include Hanami::Action::Cookies

  def handle(req, *)
    # ...
    req.cookies[:foo] # => "bar"
  end
end

action = ReadCookiesFromRackEnv.new(configuration: configuration)
action.call({"HTTP_COOKIE" => "foo=bar"})
```

They are set like a Hash:

```ruby
require "hanami/controller"
require "hanami/action/cookies"

class SetCookies < Hanami::Action
  include Hanami::Action::Cookies

  def handle(*, res)
    # ...
    res.cookies[:foo] = "bar"
  end
end

action = SetCookies.new(configuration: configuration)
action.call({}) # => [200, {"Set-Cookie" => "foo=bar"}, "..."]
```

They are removed by setting their value to `nil`:

```ruby
require "hanami/controller"
require "hanami/action/cookies"

class RemoveCookies < Hanami::Action
  include Hanami::Action::Cookies

  def handle(*, res)
    # ...
    res.cookies[:foo] = nil
  end
end

action = RemoveCookies.new(configuration: configuration)
action.call({}) # => [200, {"Set-Cookie" => "foo=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"}, "..."]
```

Default values can be set in configuration, but overridden case by case.

```ruby
require "hanami/controller"
require "hanami/action/cookies"

configuration = Hanami::Controller::Configuration.new do |config|
  config.cookies(max_age: 300) # 5 minutes
end

class SetCookies < Hanami::Action
  include Hanami::Action::Cookies

  def handle(*, res)
    # ...
    res.cookies[:foo] = { value: "bar", max_age: 100 }
  end
end

action = SetCookies.new(configuration: configuration)
action.call({}) # => [200, {"Set-Cookie" => "foo=bar; max-age=100;"}, "..."]
```

### Sessions

Actions have builtin support for Rack sessions.
Similarly to cookies, you can read the session sent by the HTTP client via
`req.session`, and also manipulate it via `res.ression`.

```ruby
require "hanami/controller"
require "hanami/action/session"

class ReadSessionFromRackEnv < Hanami::Action
  include Hanami::Action::Session

  def handle(req, *)
    # ...
    req.session[:age] # => "35"
  end
end

action = ReadSessionFromRackEnv.new(configuration: configuration)
action.call({ "rack.session" => { "age" => "35" } })
```

Values can be set like a Hash:

```ruby
require "hanami/controller"
require "hanami/action/session"

class SetSession < Hanami::Action
  include Hanami::Action::Session

  def handle(*, res)
    # ...
    res.session[:age] = 31
  end
end

action = SetSession.new(configuration: configuration)
action.call({}) # => [200, {"Set-Cookie"=>"rack.session=..."}, "..."]
```

Values can be removed like a Hash:

```ruby
require "hanami/controller"
require "hanami/action/session"

class RemoveSession < Hanami::Action
  include Hanami::Action::Session

  def handle(*, res)
    # ...
    res.session[:age] = nil
  end
end

action = RemoveSession.new(configuration: configuration)
action.call({}) # => [200, {"Set-Cookie"=>"rack.session=..."}, "..."] it removes that value from the session
```

While Hanami::Controller supports sessions natively, it's **session store agnostic**.
You have to specify the session store in your Rack middleware configuration (eg `config.ru`).

```ruby
use Rack::Session::Cookie, secret: SecureRandom.hex(64)
run Show.new(configuration: configuration)
```

### HTTP Cache

Hanami::Controller sets your headers correctly according to RFC 2616 / 14.9 for more on standard cache control directives: http://tools.ietf.org/html/rfc2616#section-14.9.1

You can easily set the Cache-Control header for your actions:

```ruby
require "hanami/controller"
require "hanami/action/cache"

class HttpCacheController < Hanami::Action
  include Hanami::Action::Cache
  cache_control :public, max_age: 600 # => Cache-Control: public, max-age=600

  def handle(*)
    # ...
  end
end
```

Expires header can be specified using `expires` method:

```ruby
require "hanami/controller"
require "hanami/action/cache"

class HttpCacheController < Hanami::Action
  include Hanami::Action::Cache
  expires 60, :public, max_age: 600 # => Expires: Sun, 03 Aug 2014 17:47:02 GMT, Cache-Control: public, max-age=600

  def handle(*)
    # ...
  end
end
```

### Conditional Get

According to HTTP specification, conditional GETs provide a way for web servers to inform clients that the response to a GET request hasn't change since the last request returning a `304 (Not Modified)` response.

Passing the `HTTP_IF_NONE_MATCH` (content identifier) or `HTTP_IF_MODIFIED_SINCE` (timestamp) headers allows the web server define if the client has a fresh version of a given resource.

You can easily take advantage of Conditional Get using `#fresh` method:

```ruby
require "hanami/controller"
require "hanami/action/cache"

class ConditionalGetController < Hanami::Action
  include Hanami::Action::Cache

  def handle(*)
    # ...
    fresh etag: resource.cache_key
    # => halt 304 with header IfNoneMatch = resource.cache_key
  end
end
```

If `resource.cache_key` is equal to `IfNoneMatch` header, then hanami will `halt 304`.

An alterative to hashing based check, is the time based check:

```ruby
require "hanami/controller"
require "hanami/action/cache"

class ConditionalGetController < Hanami::Action
  include Hanami::Action::Cache

  def handle(*)
    # ...
    fresh last_modified: resource.update_at
    # => halt 304 with header IfModifiedSince = resource.update_at.httpdate
  end
end
```

If `resource.update_at` is equal to `IfModifiedSince` header, then hanami will `halt 304`.

### Redirect

If you need to redirect the client to another resource, use `res.redirect_to`:

```ruby
class Create < Hanami::Action
  def handle(*, res)
    # ...
    res.redirect_to "http://example.com/articles/23"
  end
end

action = Create.new(configuration: configuration)
action.call({ article: { title: "Hello" }}) # => [302, {"Location" => "/articles/23"}, ""]
```

You can also redirect with a custom status code:

```ruby
class Create < Hanami::Action
  def handle(*, res)
    # ...
    res.redirect_to "http://example.com/articles/23", status: 301
  end
end

action = Create.new(configuration: configuration)
action.call({ article: { title: "Hello" }}) # => [301, {"Location" => "/articles/23"}, ""]
```

### MIME Types

`Hanami::Action` automatically sets the `Content-Type` header, according to the request.

```ruby
class Show < Hanami::Action
  def handle(*)
  end
end

action = Show.new(configuration: configuration)

response = action.call({ "HTTP_ACCEPT" => "*/*" }) # Content-Type "application/octet-stream"
response.format                                    # :all

response = action.call({ "HTTP_ACCEPT" => "text/html" }) # Content-Type "text/html"
response.format                                          # :html
```

However, you can force this value:

```ruby
class Show < Hanami::Action
  def handle(*, res)
    # ...
    res.format = :json
  end
end

action = Show.new(configuration: configuration)

response = action.call({ "HTTP_ACCEPT" => "*/*" }) # Content-Type "application/json"
response.format                                    # :json

response = action.call({ "HTTP_ACCEPT" => "text/html" }) # Content-Type "application/json"
response.format                                          # :json
```

You can restrict the accepted MIME types:

```ruby
class Show < Hanami::Action
  accept :html, :json

  def handle(*)
    # ...
  end
end

# When called with "\*/\*"            => 200
# When called with "text/html"        => 200
# When called with "application/json" => 200
# When called with "application/xml"  => 415
```

You can check if the requested MIME type is accepted by the client.

```ruby
class Show < Hanami::Action
  def handle(req, res)
    # ...
    # @_env["HTTP_ACCEPT"] # => "text/html,application/xhtml+xml,application/xml;q=0.9"

    req.accept?("text/html")        # => true
    req.accept?("application/xml")  # => true
    req.accept?("application/json") # => false
    res.format                      # :html



    # @_env["HTTP_ACCEPT"] # => "*/*"

    req.accept?("text/html")        # => true
    req.accept?("application/xml")  # => true
    req.accept?("application/json") # => true
    res.format                      # :html
  end
end
```

Hanami::Controller is shipped with an extensive list of the most common MIME types.
Also, you can register your own:

```ruby
configuration = Hanami::Controller::Configuration.new do |config|
  config.format custom: "application/custom"
end

class Index < Hanami::Action
  def handle(*)
  end
end

action = Index.new(configuration: configuration)

response = action.call({ "HTTP_ACCEPT" => "application/custom" }) # => Content-Type "application/custom"
response.format                                                   # => :custom

class Show < Hanami::Action
  def handle(*, res)
    # ...
    res.format = :custom
  end
end

action = Show.new(configuration: configuration)

response = action.call({ "HTTP_ACCEPT" => "*/*" }) # => Content-Type "application/custom"
response.format                                    # => :custom
```

### Streamed Responses

When the work to be done by the server takes time, it may be a good idea to stream your response. Here's an example of a streamed CSV.

```ruby
configuration = Hanami::Controller::Configuration.new do |config|
  config.format csv: 'text/csv'
end

class Csv < Hanami::Action
  def handle(*, res)
    res.format = :csv
    res.body = Enumerator.new do |yielder|
      yielder << csv_header

      # Expensive operation is streamed as each line becomes available
      csv_body.each_line do |line|
        yielder << line
      end
    end
  end
end
```

Note:
* In development, Hanami' code reloading needs to be disabled for streaming to work. This is because `Shotgun` interferes with the streaming action. You can disable it like this `hanami server --code-reloading=false`
* Streaming does not work with WEBrick as it buffers its response. We recommend using `puma`, though you may find success with other servers

### No rendering, please

Hanami::Controller is designed to be a pure HTTP endpoint, rendering belongs to other layers of MVC.
You can set the body directly (see [response](#response)), or use [Hanami::View](https://github.com/hanami/view).

### Controllers

A Controller is nothing more than a logical group of actions: just a Ruby module.

```ruby
module Articles
  class Index < Hanami::Action
    # ...
  end

  class Show < Hanami::Action
    # ...
  end
end

Articles::Index.new(configuration: configuration).call({})
```

### Hanami::Router integration

```ruby
require "hanami/router"
require "hanami/controller"

module Web
  module Controllers
    module Books
      class Show < Hanami::Action
        def handle(*)
        end
      end
    end
  end
end

configuration = Hanami::Controller::Configuration.new
router = Hanami::Router.new(configuration: configuration, namespace: Web::Controllers) do
  get "/books/:id", "books#show"
end
```

### Rack integration

Hanami::Controller is compatible with Rack. If you need to use any Rack middleware, please mount them in `config.ru`.

### Configuration

Hanami::Controller can be configured via `Hanami::Controller::Configuration`.
It supports a few options:

```ruby
require "hanami/controller"

configuration = Hanami::Controller::Configuration.new do |config|
  # If the given exception is raised, return that HTTP status
  # It can be used multiple times
  # Argument: hash, empty by default
  #
  config.handle_exception ArgumentError => 404

  # Register a format to MIME type mapping
  # Argument: hash, key: format symbol, value: MIME type string, empty by default
  #
  config.format custom: "application/custom"

  # Define a default format to set as `Content-Type` header for response,
  # unless otherwise specified.
  # If not defined here, it will return Rack's default: `application/octet-stream`
  # Argument: symbol, it should be already known. defaults to `nil`
  #
  config.default_response_format = :html

  # Define a default charset to return in the `Content-Type` response header
  # If not defined here, it returns `utf-8`
  # Argument: string, defaults to `nil`
  #
  config.default_charset = "koi8-r"
end
```

### Thread safety

An Action is **immutable**, it works without global state, so it's thread-safe by design.

## Versioning

__Hanami::Controller__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright © 2014 Hanami Team – Released under MIT License
