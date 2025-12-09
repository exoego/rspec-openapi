# -*- encoding: utf-8 -*-
# stub: hanami-utils 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hanami-utils".freeze
  s.version = "2.3.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Luca Guidi".freeze]
  s.date = "1980-01-02"
  s.description = "Hanami utilities".freeze
  s.email = ["me@lucaguidi.com".freeze]
  s.homepage = "http://hanamirb.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Ruby core extentions and Hanami utilities".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-transformer>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<bigdecimal>.freeze, ["~> 3.1".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 1.6".freeze, "< 3".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0".freeze])
end
