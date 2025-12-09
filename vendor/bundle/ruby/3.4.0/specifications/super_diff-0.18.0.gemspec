# -*- encoding: utf-8 -*-
# stub: super_diff 0.18.0 ruby lib

Gem::Specification.new do |s|
  s.name = "super_diff".freeze
  s.version = "0.18.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/splitwise/super_diff/issues", "changelog_uri" => "https://github.com/splitwise/super_diff/blob/main/CHANGELOG.md", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/splitwise/super_diff" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Elliot Winkler".freeze, "Splitwise, Inc.".freeze]
  s.date = "2025-12-05"
  s.description = "SuperDiff is a gem that hooks into RSpec to intelligently display the\ndifferences between two data structures of any type.\n".freeze
  s.email = ["oss-community@splitwise.com".freeze]
  s.homepage = "https://github.com/splitwise/super_diff".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "A better way to view differences between complex data structures in RSpec.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<attr_extras>.freeze, [">= 6.2.4".freeze])
  s.add_runtime_dependency(%q<diff-lcs>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<patience_diff>.freeze, [">= 0".freeze])
end
