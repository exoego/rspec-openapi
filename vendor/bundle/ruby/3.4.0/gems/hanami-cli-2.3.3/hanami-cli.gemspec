# frozen_string_literal: true

require_relative "lib/hanami/cli/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-cli"
  spec.version       = Hanami::CLI::VERSION
  spec.authors       = ["Hanakai team"]
  spec.email         = ["info@hanakai.org"]

  spec.summary       = "Hanami CLI"
  spec.description   = "Hanami command line"
  spec.homepage      = "https://hanamirb.org"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hanami/cli"
  spec.metadata["changelog_uri"] = "https://github.com/hanami/cli/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.required_ruby_version = ">= 3.2"

  spec.add_dependency "bundler", ">= 2.1"
  spec.add_dependency "dry-cli", "~> 1.0", ">= 1.1.0"
  spec.add_dependency "dry-files", "~> 1.0", ">= 1.0.2", "< 2"
  spec.add_dependency "dry-inflector", "~> 1.0", "< 2"
  spec.add_dependency "irb"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "rackup"

  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "puma"
end
