# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-openapi.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] || '6.0.6.1'

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0')
  gem 'hanami', ENV['HANAMI_VERSION'] || '2.1.0'
  gem 'hanami-controller', ENV['HANAMI_VERSION'] || '2.1.0'
  gem 'hanami-router', ENV['HANAMI_VERSION'] || '2.1.0'

  gem 'dry-logger', '1.0.3'
end

gem 'concurrent-ruby', '1.3.4'

gem 'roda'

gem 'rails-dom-testing', '~> 2.2'
gem 'rspec-rails', '>= 6.0'

group :test do
  gem 'simplecov', git: 'https://github.com/exoego/simplecov.git', branch: 'branch-fix'
  gem 'simplecov-cobertura'
  gem 'super_diff'
end

group :development do
  gem 'code-scanning-rubocop'
  gem 'pry'
end
