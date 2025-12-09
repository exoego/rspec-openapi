# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/utils/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-utils"
  spec.version       = Hanami::Utils::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]
  spec.description   = "Hanami utilities"
  spec.summary       = "Ruby core extentions and Hanami utilities"
  spec.homepage      = "http://hanamirb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-utils.gemspec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.required_ruby_version = ">= 3.2"

  spec.add_dependency "dry-core", "~> 1.0", "< 2"
  spec.add_dependency "dry-transformer", "~> 1.0", "< 2"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
  spec.add_dependency "bigdecimal", "~> 3.1"

  spec.add_development_dependency "bundler", ">= 1.6", "< 3"
  spec.add_development_dependency "rake",    "~> 13"
  spec.add_development_dependency "rspec",   "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.0"
end
