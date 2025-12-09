# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'optimist'

Gem::Specification.new do |spec|
  spec.name          = "optimist"
  spec.version       = Optimist::VERSION
  spec.authors       = ["William Morgan", "Keenan Brock", "Jason Frey"]
  spec.email         = "keenan@thebrocks.net"
  spec.summary       = "Optimist is a commandline option parser for Ruby that just gets out of your way."
  spec.description   = "Optimist is a commandline option parser for Ruby that just
gets out of your way. One line of code per option is all you need to write.
For that, you get a nice automatically-generated help page, robust option
parsing, command subcompletion, and sensible defaults for everything you don't
specify."
  spec.homepage      = "http://manageiq.github.io/optimist/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.metadata    = {
    "changelog_uri"   => "https://github.com/ManageIQ/optimist/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/ManageIQ/optimist/",
    "bug_tracker_uri" => "https://github.com/ManageIQ/optimist/issues",
  }

  spec.require_paths = ["lib"]

  spec.add_development_dependency "chronic"
  spec.add_development_dependency "manageiq-style", ">= 1.5.3"
  spec.add_development_dependency "minitest",       "~> 5.25"
  spec.add_development_dependency "rake",           ">= 10.0"
end
