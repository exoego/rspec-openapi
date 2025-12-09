# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative "lib/code_scanning/rubocop/version"

Gem::Specification.new do |spec|
  spec.name          = "code-scanning-rubocop"
  spec.version       = CodeScanning::Rubocop::VERSION
  spec.authors       = ["Arthur Neves"]
  spec.email         = ["arthurnn@gmail.com"]

  spec.summary       = "Extra formater to make rubocop compatible with GitHub's code-scanning feature."
  spec.description   = "This gem adds a SARIF formatter to rubocop, so we can export alerts to code-scanning inside GitHub."
  spec.homepage      = "https://github.com/arthurnn/code-scanning-rubocop"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arthurnn/code-scanning-rubocop"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubocop", "~> 1.0"
end
