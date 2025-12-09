require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

SimpleCov.start do
  project_name 'hansi'
  coverage_dir '.coverage'
  add_filter "/spec/"
  add_filter "/lib/hansi/mode_detector.rb"
end
