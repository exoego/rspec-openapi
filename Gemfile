# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in rspec-openapi.gemspec
gemspec

gem 'rails', ENV['RAILS_VERSION'] || '6.0.3.7'
gem 'roda'
gem 'rspec-rails'

group :test do
  gem 'simplecov'
  gem 'simplecov-cobertura'
  gem 'super_diff'
end

group :development do
  gem 'code-scanning-rubocop'
  gem 'pry'
end
