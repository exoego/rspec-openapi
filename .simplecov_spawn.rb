# frozen_string_literal: true

unless ENV['COVERAGE'] && ENV['COVERAGE'].empty?
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.at_fork.call(Process.pid)
  SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
  ])
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/scripts/'
  end
end
