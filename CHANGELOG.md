## v0.3.0

* Initial support of rack-test and non-Rails apps

## v0.2.2

* Allow disabling `example` by `RSpec::OpenAPI.enable_example = false`

## v0.2.1

* Generate `example` of request body and path / query params
  [#4](https://github.com/k0kubun/rspec-openapi/issues/4)
* Remove a wrapper param created by Rails in request body
  [#4](https://github.com/k0kubun/rspec-openapi/issues/4)

## v0.2.0

* Generate `example` of response body [#3](https://github.com/k0kubun/rspec-openapi/issues/3)

## v0.1.5

* Support detecting `float` type [#2](https://github.com/k0kubun/rspec-openapi/issues/2)

## v0.1.4

* Avoid NoMethodError on nil Content-Type
* Include a space between controller and action in summary

## v0.1.3

* Add `RSpec::OpenAPI.comment` configuration

## v0.1.2

* Generate `required: true` for path params [#1](https://github.com/k0kubun/rspec-openapi/issues/1)

## v0.1.1

* Generate a path like `/{id}` instead of `/:id`

## v0.1.0

* Initial release
