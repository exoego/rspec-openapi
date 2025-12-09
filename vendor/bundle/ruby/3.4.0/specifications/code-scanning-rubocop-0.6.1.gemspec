# -*- encoding: utf-8 -*-
# stub: code-scanning-rubocop 0.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "code-scanning-rubocop".freeze
  s.version = "0.6.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/arthurnn/code-scanning-rubocop", "source_code_uri" => "https://github.com/arthurnn/code-scanning-rubocop" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Arthur Neves".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-02-02"
  s.description = "This gem adds a SARIF formatter to rubocop, so we can export alerts to code-scanning inside GitHub.".freeze
  s.email = ["arthurnn@gmail.com".freeze]
  s.homepage = "https://github.com/arthurnn/code-scanning-rubocop".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.3.3".freeze
  s.summary = "Extra formater to make rubocop compatible with GitHub's code-scanning feature.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.0".freeze])
end
