# frozen_string_literal: true

unless ENV['COVERAGE'] && ENV['COVERAGE'].empty?
  require 'simplecov'
  require 'simplecov-cobertura'

  # Configure before at_fork rather than in the start block below. at_fork's
  # lambda calls SimpleCov.start itself, and once Coverage is running the mode
  # is fixed, so asking for branches afterwards is too late. The runs spawned as
  # `ruby -r./.simplecov_spawn` (the minitest ones) hit exactly that and were
  # recording lines only, contributing no branch data at all.
  SimpleCov.configure do
    enable_coverage :branch
    add_filter '/spec/'
    add_filter '/scripts/'
  end

  SimpleCov.at_fork.call(Process.pid)
  SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
  ])
  SimpleCov.start
end
