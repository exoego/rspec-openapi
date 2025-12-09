# -*- encoding: utf-8 -*-
# stub: hansi 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hansi".freeze
  s.version = "0.2.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Haase".freeze]
  s.date = "2022-05-23"
  s.description = "Der ANSI Hansi - create colorized console output.".freeze
  s.email = "konstantin.mailinglists@googlemail.com".freeze
  s.homepage = "https://github.com/rkh/hansi".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Hipster ANSI color library".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<tool>.freeze, ["~> 0.2".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0".freeze])
end
