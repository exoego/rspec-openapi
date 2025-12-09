# -*- encoding: utf-8 -*-
# stub: hanami-cli 2.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "hanami-cli".freeze
  s.version = "2.3.3".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/hanami/cli/blob/master/CHANGELOG.md", "homepage_uri" => "https://hanamirb.org", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/hanami/cli" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hanakai team".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "Hanami command line".freeze
  s.email = ["info@hanakai.org".freeze]
  s.executables = ["hanami".freeze]
  s.files = ["exe/hanami".freeze]
  s.homepage = "https://hanamirb.org".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Hanami CLI".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<bundler>.freeze, [">= 2.1".freeze])
  s.add_runtime_dependency(%q<dry-cli>.freeze, ["~> 1.0".freeze, ">= 1.1.0".freeze])
  s.add_runtime_dependency(%q<dry-files>.freeze, ["~> 1.0".freeze, ">= 1.0.2".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<dry-inflector>.freeze, ["~> 1.0".freeze, "< 2".freeze])
  s.add_runtime_dependency(%q<irb>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6".freeze])
  s.add_runtime_dependency(%q<rackup>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<puma>.freeze, [">= 0".freeze])
end
