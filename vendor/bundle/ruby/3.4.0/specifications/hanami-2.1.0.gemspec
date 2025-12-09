# -*- encoding: utf-8 -*-
# stub: hanami 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hanami".freeze
  s.version = "2.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "2024-02-27"
  s.description = "Hanami is a web framework for Ruby".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "http://hanamirb.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.5.6".freeze
  s.summary = "The web, with simplicity".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<bundler>.freeze, [">= 1.16".freeze, "< 3".freeze])
  s.add_runtime_dependency(%q<dry-configurable>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-inflector>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-monitor>.freeze, ["~> 1.0".freeze, ">= 1.0.1".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-system>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-logger>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<hanami-cli>.freeze, ["~> 2.1".freeze])
  s.add_runtime_dependency(%q<hanami-utils>.freeze, ["~> 2.1".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8".freeze])
  s.add_development_dependency(%q<rack-test>.freeze, ["~> 1.1".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
end
