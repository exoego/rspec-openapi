unless ENV["COVERAGE"] && ENV["COVERAGE"].empty?
  require 'simplecov'
  require 'simplecov-cobertura'

  SimpleCov.command_name 'spawn'
  SimpleCov.at_fork.call(Process.pid)
  SimpleCov.formatter SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.start
end