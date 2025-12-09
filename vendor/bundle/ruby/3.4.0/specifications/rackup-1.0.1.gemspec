# -*- encoding: utf-8 -*-
# stub: rackup 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rackup".freeze
  s.version = "1.0.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Samuel Williams".freeze, "Jeremy Evans".freeze]
  s.date = "2024-10-23"
  s.homepage = "https://github.com/rack/rackup".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.5.11".freeze
  s.summary = "A general server command for Rack applications.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, ["< 3".freeze])
  s.add_runtime_dependency(%q<webrick>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0".freeze])
  s.add_development_dependency(%q<minitest-global_expectations>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest-sprint>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
end
