# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/controller/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-controller"
  spec.version       = Hanami::Controller::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]
  spec.description   = "Complete, fast and testable actions for Rack"
  spec.summary       = "Complete, fast and testable actions for Rack and Hanami"
  spec.homepage      = "http://hanamirb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-controller.gemspec`.split($/)
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "rack", "~> 2.0"
  spec.add_dependency "hanami-utils", "~> 2.1"
  spec.add_dependency "dry-configurable", "~> 1.0", "< 2"
  spec.add_dependency "dry-core", "~> 1.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_development_dependency "bundler",   ">= 1.6", "< 3"
  spec.add_development_dependency "rack-test", "~> 2.0"
  spec.add_development_dependency "rake",      "~> 13"
  spec.add_development_dependency "rspec",     "~> 3.9"
  spec.add_development_dependency "rubocop",   "~> 1.0"
end
