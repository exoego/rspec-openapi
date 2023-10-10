## v0.9.0
- bugfix: Fix engine path resolution
  [#113](https://github.com/exoego/rspec-openapi/pull/113)
- bugfix: fix multiple uploaded files
  [#117](https://github.com/exoego/rspec-openapi/pull/117), [#126](https://github.com/exoego/rspec-openapi/pull/126)
- feat: Add required_request_params to metadata
 [#114](https://github.com/exoego/rspec-openapi/pull/114)
- bugfix(minitest):
  [#128](https://github.com/exoego/rspec-openapi/pull/128)
- doc(minitest): Add instructions for minitest triggered yaml generation
  [#116](https://github.com/exoego/rspec-openapi/pull/116)
- chore: Don't dump records into temporary file
  [#127](https://github.com/exoego/rspec-openapi/pull/127)

## v0.8.1
- bugfix: Empty `required` array should not be present.
  [#111](https://github.com/exoego/rspec-openapi/pull/111)

## v0.8.0
- Set `required` in request body and response body
  [#95](https://github.com/exoego/rspec-openapi/pull/95), [#98](https://github.com/exoego/rspec-openapi/pull/98)
- Generate OpenAPI with minitest instead of RSpec
  [#90](https://github.com/exoego/rspec-openapi/pull/90)
- Generate security schemas via RSpec::OpenAPI.security_schemes
  [#84](https://github.com/exoego/rspec-openapi/pull/84)
- Bunch of refactorings

## v0.7.2
- $ref enhancements: Support $ref in arbitrary depth
  [#82](https://github.com/k0kubun/rspec-openapi/pull/82)

## v0.7.1
- $ref enhancements: Auto-generate components referenced in "items"
  [#80](https://github.com/k0kubun/rspec-openapi/pull/80)
- Administration
  - Setup RuboCop
    [#73](https://github.com/k0kubun/rspec-openapi/pull/73)
  - Setup CodeQL
    [#73](https://github.com/k0kubun/rspec-openapi/pull/73)
  - Bump Rails v6.0.3.x to fix bundle failure
    [#72](https://github.com/k0kubun/rspec-openapi/pull/72)

## v0.7.0
- Generate Response Headers
  [#69](https://github.com/k0kubun/rspec-openapi/pull/69)
- Initial support for $ref
  [#67](https://github.com/k0kubun/rspec-openapi/pull/67)
- Fixed an empty array is turned into nullable object wrongly
  [#70](https://github.com/k0kubun/rspec-openapi/pull/70)

## v0.6.1

* Stabilize the order parameter objects and preserve newer examples
  [#59](https://github.com/k0kubun/rspec-openapi/pull/59)

## v0.6.0

* Replace `RSpec::OpenAPI.server_urls` with `RSpec::OpenAPI.servers`
  [#60](https://github.com/k0kubun/rspec-openapi/pull/60)

## v0.5.1

* Clarify the version requirement for actionpack
  [#62](https://github.com/k0kubun/rspec-openapi/pull/62)

## v0.5.0

* Overwrite fields in an existing schema file instead of leaving all existing fields as is
  [#55](https://github.com/k0kubun/rspec-openapi/pull/55)

## v0.4.8

* Fix a bug in nested parameters handling
  [#46](https://github.com/k0kubun/rspec-openapi/pull/46)

## v0.4.7

* Add `info` config hash
  [#43](https://github.com/k0kubun/rspec-openapi/pull/43)

## v0.4.6

* Fix "No route matched for" error in engine routes
  [#38](https://github.com/k0kubun/rspec-openapi/pull/38)

## v0.4.5

* Fix linter issues for `tags` and `summary`
  [#40](https://github.com/k0kubun/rspec-openapi/pull/40)

## v0.4.4

* De-duplicate parameters by a combination of `name` and `in`
  [#39](https://github.com/k0kubun/rspec-openapi/pull/39)

## v0.4.3

* Allow customizing `schema`, `description`, and `tags` through `:openapi` metadata
  [#36](https://github.com/k0kubun/rspec-openapi/pull/36)

## v0.4.2

* Allow using Proc as `RSpec::OpenAPI.path`
  [#35](https://github.com/k0kubun/rspec-openapi/pull/35)

## v0.4.1

* Add `RSpec::OpenAPI.example_types` to hook types other than `type: :request`.
  [#32](https://github.com/k0kubun/rspec-openapi/pull/32)

## v0.4.0

* Drop `RSpec::OpenAPI.output` introduced in v0.3.20
* Guess whether it's JSON or not by the extension of `RSpec::OpenAPI.path`

## v0.3.20

* Add `RSpec::OpenAPI.output` config to output JSON
  [#31](https://github.com/k0kubun/rspec-openapi/pull/31)

## v0.3.19

* Add `server_urls` and `request_headers` configs
  [#30](https://github.com/k0kubun/rspec-openapi/pull/30)

## v0.3.18

* Support nested query parameters
  [#29](https://github.com/k0kubun/rspec-openapi/pull/29)

## v0.3.17

* Rescue NotImplementedError in the after suite hook as well
  [#28](https://github.com/k0kubun/rspec-openapi/pull/28)

## v0.3.16

* Use `media_type` instead of `content_type` for Rails 6.1
  [#26](https://github.com/k0kubun/rspec-openapi/pull/26)
* Avoid crashing the after suite hook when it fails to build schema
  [#27](https://github.com/k0kubun/rspec-openapi/pull/27)

## v0.3.15

* Fix an error when Content-Disposition header is inline
  [#24](https://github.com/k0kubun/rspec-openapi/pull/24)

## v0.3.14

* Avoid an error when an application calls `request.body.read`
  [#20](https://github.com/k0kubun/rspec-openapi/pull/20)

## v0.3.13

* Avoid crashing when there's no request made in a spec
  [#19](https://github.com/k0kubun/rspec-openapi/pull/19)

## v0.3.12

* Generate `nullable: true` for null fields in schema
  [#18](https://github.com/k0kubun/rspec-openapi/pull/18)

## v0.3.11

* Show a filename as an `example` for `ActionDispatch::Http::UploadedFile`
  [#17](https://github.com/k0kubun/rspec-openapi/pull/17)

## v0.3.10

* Add `info.version`
  [#16](https://github.com/k0kubun/rspec-openapi/pull/16)

## v0.3.9

* Initial support for multipart/form-data
  [#12](https://github.com/k0kubun/rspec-openapi/pull/12)

## v0.3.8

* Generate `type: 'number', format: 'float'` instead of `type: 'float'` for Float
  [#11](https://github.com/k0kubun/rspec-openapi/issues/11)

## v0.3.7

* Classify tag names and remove controller names from summary in Rails

## v0.3.6

* Fix documents generated by Rails engines

## v0.3.5

* Support finding routes in Rails engines

## v0.3.4

* Generate tags by controller names
  [#10](https://github.com/k0kubun/rspec-openapi/issues/10)

## v0.3.3

* Avoid `JSON::ParserError` when a response body is no content
  [#9](https://github.com/k0kubun/rspec-openapi/issues/9)

## v0.3.2

* Stop generating format as path parameters in Rails
  [#8](https://github.com/k0kubun/rspec-openapi/issues/8)

## v0.3.1

* Add `RSpec::OpenAPI.description_builder` config to dynamically generate a description [experimental]
  [#6](https://github.com/k0kubun/rspec-openapi/issues/6)

## v0.3.0

* Initial support of rack-test and non-Rails apps [#5](https://github.com/k0kubun/rspec-openapi/issues/5)

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
