# frozen_string_literal: true

require_relative 'lib/rspec/openapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-openapi'
  spec.version       = RSpec::OpenAPI::VERSION
  spec.authors       = ['Takashi Kokubun', 'TATSUNO Yasuhiro']
  spec.email         = ['takashikkbn@gmail.com', 'ytatsuno.jp@gmail.com']

  spec.summary       = 'Generate OpenAPI schema from RSpec request specs'
  spec.description   = 'Generate OpenAPI from RSpec request specs'
  spec.homepage      = 'https://github.com/exoego/rspec-openapi'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = File.join(spec.homepage, 'blob/master/CHANGELOG.md')

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 5.2.0'
  spec.add_dependency 'rspec-core'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
