# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-openapi.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] || '6.0.3.7'
gem 'roda'
gem 'rspec-rails'

group :test do
  gem 'super_diff'
  gem 'simplecov'
  gem 'simplecov-cobertura'
end

group :development do
  gem 'code-scanning-rubocop'
  gem 'pry'
end
