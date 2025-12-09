# -*- encoding: utf-8 -*-
# stub: dry-monitor 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-monitor".freeze
  s.version = "1.0.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/dry-rb/dry-monitor/issues", "changelog_uri" => "https://github.com/dry-rb/dry-monitor/blob/main/CHANGELOG.md", "source_code_uri" => "https://github.com/dry-rb/dry-monitor" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Piotr Solnica".freeze]
  s.date = "2022-11-17"
  s.description = "Monitoring and instrumentation APIs".freeze
  s.email = ["piotr.solnica@gmail.com".freeze]
  s.homepage = "https://dry-rb.org/gems/dry-monitor".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Monitoring and instrumentation APIs".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<dry-configurable>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-events>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rouge>.freeze, ["~> 2.0".freeze, ">= 2.2.1".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
end
