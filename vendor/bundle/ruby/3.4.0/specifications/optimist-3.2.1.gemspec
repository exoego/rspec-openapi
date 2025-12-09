# -*- encoding: utf-8 -*-
# stub: optimist 3.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "optimist".freeze
  s.version = "3.2.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/ManageIQ/optimist/issues", "changelog_uri" => "https://github.com/ManageIQ/optimist/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/ManageIQ/optimist/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["William Morgan".freeze, "Keenan Brock".freeze, "Jason Frey".freeze]
  s.date = "2025-03-19"
  s.description = "Optimist is a commandline option parser for Ruby that just\ngets out of your way. One line of code per option is all you need to write.\nFor that, you get a nice automatically-generated help page, robust option\nparsing, command subcompletion, and sensible defaults for everything you don't\nspecify.".freeze
  s.email = "keenan@thebrocks.net".freeze
  s.homepage = "http://manageiq.github.io/optimist/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.22".freeze
  s.summary = "Optimist is a commandline option parser for Ruby that just gets out of your way.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<chronic>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<manageiq-style>.freeze, [">= 1.5.3".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.25".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 10.0".freeze])
end
