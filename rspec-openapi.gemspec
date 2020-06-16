require_relative 'lib/rspec/openapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-openapi'
  spec.version       = RSpec::OpenAPI::VERSION
  spec.authors       = ['Takashi Kokubun']
  spec.email         = ['takashikkbn@gmail.com']

  spec.summary       = %q{Generate OpenAPI specs from RSpec request specs without any original DSL}
  spec.description   = %q{Generate OpenAPI specs from RSpec request specs without any original DSL}
  spec.homepage      = 'https://github.com/k0kubun/rspec-openapi'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = 'TODO'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rspec'
end
