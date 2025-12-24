# frozen_string_literal: true

# Bootstrap SimpleCov before any library code is loaded
# This file must be required BEFORE rspec/openapi in .rspec

if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
  ])
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
    add_filter '/scripts/'
  end
end
