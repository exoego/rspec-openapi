# -*- encoding: utf-8 -*-
# stub: dry-system 1.2.5 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-system".freeze
  s.version = "1.2.5".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "bug_tracker_uri" => "https://github.com/dry-rb/dry-system/issues", "changelog_uri" => "https://github.com/dry-rb/dry-system/blob/main/CHANGELOG.md", "funding_uri" => "https://github.com/sponsors/hanami", "source_code_uri" => "https://github.com/dry-rb/dry-system" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hanakai team".freeze]
  s.date = "2025-11-30"
  s.description = "Organize your code into reusable components".freeze
  s.email = ["info@hanakai.org".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "CHANGELOG.md".freeze, "LICENSE".freeze]
  s.files = ["CHANGELOG.md".freeze, "LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://dry-rb.org/gems/dry-system".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1.0".freeze)
  s.rubygems_version = "3.3.27".freeze
  s.summary = "Organize your code into reusable components".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<dry-auto_inject>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<dry-configurable>.freeze, ["~> 1.3".freeze])
  s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 1.1".freeze])
  s.add_runtime_dependency(%q<dry-inflector>.freeze, ["~> 1.1".freeze])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
end
