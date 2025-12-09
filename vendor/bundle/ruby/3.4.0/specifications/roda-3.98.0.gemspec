# -*- encoding: utf-8 -*-
# stub: roda 3.98.0 ruby lib

Gem::Specification.new do |s|
  s.name = "roda".freeze
  s.version = "3.98.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/jeremyevans/roda/issues", "changelog_uri" => "https://roda.jeremyevans.net/rdoc/files/CHANGELOG.html", "documentation_uri" => "https://roda.jeremyevans.net/documentation.html", "mailing_list_uri" => "https://github.com/jeremyevans/roda/discussions", "source_code_uri" => "https://github.com/jeremyevans/roda" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jeremy Evans".freeze]
  s.date = "1980-01-02"
  s.email = ["code@jeremyevans.net".freeze]
  s.extra_rdoc_files = ["MIT-LICENSE".freeze]
  s.files = ["MIT-LICENSE".freeze]
  s.homepage = "https://roda.jeremyevans.net".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Routing tree web toolkit".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rack>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, [">= 5.7.0".freeze])
  s.add_development_dependency(%q<minitest-hooks>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest-global_expectations>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<tilt>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<erubi>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rack_csrf>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<json>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<mail>.freeze, [">= 0".freeze])
end
