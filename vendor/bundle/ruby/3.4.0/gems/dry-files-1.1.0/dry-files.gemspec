# frozen_string_literal: true

# this file is synced from dry-rb/template-gem project

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/files/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-files"
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]
  spec.license       = "MIT"
  spec.version       = Dry::Files::VERSION.dup

  spec.summary       = "file utilities"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-files"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-files.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/dry-rb/dry-files/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/dry-rb/dry-files"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/dry-rb/dry-files/issues"

  spec.required_ruby_version = ">= 2.7.0"

  # to update dependencies edit project.yml

  spec.add_development_dependency "rspec", "~> 3.10"
end
