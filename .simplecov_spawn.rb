# frozen_string_literal: true

unless ENV['COVERAGE'] && ENV['COVERAGE'].empty?
  require 'simplecov'
  require 'simplecov-cobertura'

  # Give every process a unique command_name so results merge instead of overwriting each other under a
  # shared name (simplecov >= 1.0 names forks "subprocess: N", which collides across spawns).
  SimpleCov.command_name("rspec-#{Process.pid}")
  SimpleCov.at_fork.call(Process.pid)
  SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
  ])
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
    add_filter '/scripts/'
  end
end
