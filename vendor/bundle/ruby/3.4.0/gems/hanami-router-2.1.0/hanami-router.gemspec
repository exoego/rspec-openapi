# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/router/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-router"
  spec.version       = Hanami::Router::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]
  spec.description   = "Rack compatible HTTP router for Ruby"
  spec.summary       = "Rack compatible HTTP router for Ruby and Hanami"
  spec.homepage      = "http://hanamirb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-router.gemspec`.split($/)
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "rack",               "~> 2.0"
  spec.add_dependency "mustermann",         "~> 3.0"
  spec.add_dependency "mustermann-contrib", "~> 3.0"

  spec.add_development_dependency "bundler",   ">= 1.6", "< 3"
  spec.add_development_dependency "rake",      "~> 13"
  spec.add_development_dependency "rack-test", "~> 1.0"
  spec.add_development_dependency "rspec",     "~> 3.8"

  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.0"
end
