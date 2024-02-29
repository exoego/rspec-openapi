# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-openapi.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] || '6.0.3.7'
gem 'rails-dom-testing', '~> 2.2'
gem 'roda'
gem 'rspec-rails'

group :test do
  gem 'simplecov', git: 'https://github.com/exoego/simplecov.git', branch: 'branch-fix'
  gem 'simplecov-cobertura'
  gem 'super_diff'
end

group :development do
  gem 'code-scanning-rubocop'
  gem 'pry'
end
