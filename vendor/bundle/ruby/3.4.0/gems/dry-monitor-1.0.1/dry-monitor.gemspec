# frozen_string_literal: true

# this file is synced from dry-rb/template-gem project

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/monitor/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-monitor"
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.license       = "MIT"
  spec.version       = Dry::Monitor::VERSION.dup

  spec.summary       = "Monitoring and instrumentation APIs"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-monitor"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-monitor.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/dry-rb/dry-monitor/blob/main/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/dry-rb/dry-monitor"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/dry-rb/dry-monitor/issues"

  spec.required_ruby_version = ">= 2.7.0"

  # to update dependencies edit project.yml
  spec.add_runtime_dependency "dry-configurable", "~> 1.0", "< 2"
  spec.add_runtime_dependency "dry-core", "~> 1.0", "< 2"
  spec.add_runtime_dependency "dry-events", "~> 1.0", "< 2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rouge", "~> 2.0", ">= 2.2.1"
  spec.add_development_dependency "rspec"
end
