# frozen_string_literal: true

# Coverage is opt-in: it costs roughly a quarter of each spawned run, so only
# instrument when COVERAGE is set to something non-empty, as the one CI job
# that uploads to codecov does.
unless ENV.fetch('COVERAGE', '').empty?
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

  # at_fork names a child "(subprocess: N)" from a serial the parent counts up
  # on each fork. A spawned process never forked, so its serial is 0 in every
  # spawn and the results would overwrite each other under one shared name.
  SimpleCov.command_name("rspec-#{Process.pid}")
  SimpleCov.at_fork.call(Process.pid)
  SimpleCov.formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::CoberturaFormatter,
  ])
  SimpleCov.start
end
