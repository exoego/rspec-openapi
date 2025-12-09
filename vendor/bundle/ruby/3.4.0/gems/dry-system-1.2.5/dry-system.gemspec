# frozen_string_literal: true

# This file is synced from hanakai-rb/repo-sync. To update it, edit repo-sync.yml.

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/system/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-system"
  spec.authors       = ["Hanakai team"]
  spec.email         = ["info@hanakai.org"]
  spec.license       = "MIT"
  spec.version       = Dry::System::VERSION.dup

  spec.summary       = "Organize your code into reusable components"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-system"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-system.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/dry-rb/dry-system/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/dry-rb/dry-system"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/dry-rb/dry-system/issues"
  spec.metadata["funding_uri"]       = "https://github.com/sponsors/hanami"

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_runtime_dependency "dry-auto_inject", "~> 1.1"
  spec.add_runtime_dependency "dry-configurable", "~> 1.3"
  spec.add_runtime_dependency "dry-core", "~> 1.1"
  spec.add_runtime_dependency "dry-inflector", "~> 1.1"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end

