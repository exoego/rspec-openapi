# -*- encoding: utf-8 -*-
# stub: hanami-router 2.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hanami-router".freeze
  s.version = "2.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "2024-02-27"
  s.description = "Rack compatible HTTP router for Ruby".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "http://hanamirb.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.5.6".freeze
  s.summary = "Rack compatible HTTP router for Ruby and Hanami".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, ["~> 2.0".freeze])
  s.add_runtime_dependency(%q<mustermann>.freeze, ["~> 3.0".freeze])
  s.add_runtime_dependency(%q<mustermann-contrib>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 1.6".freeze, "< 3".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13".freeze])
  s.add_development_dependency(%q<rack-test>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.0".freeze])
end
