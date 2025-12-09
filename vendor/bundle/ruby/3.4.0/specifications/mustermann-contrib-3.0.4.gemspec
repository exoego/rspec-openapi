# -*- encoding: utf-8 -*-
# stub: mustermann-contrib 3.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "mustermann-contrib".freeze
  s.version = "3.0.4".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Konstantin Haase".freeze, "Zachary Scott".freeze]
  s.date = "1980-01-02"
  s.description = "Adds many plugins to Mustermann".freeze
  s.email = "sinatrarb@googlegroups.com".freeze
  s.homepage = "https://github.com/sinatra/mustermann".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Collection of extensions for Mustermann".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<mustermann>.freeze, ["= 3.0.4".freeze])
  s.add_runtime_dependency(%q<hansi>.freeze, ["~> 0.2.0".freeze])
end
