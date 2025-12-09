require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/*_test.rb"
end

begin
require 'coveralls/rake/task'
Coveralls::RakeTask.new
rescue LoadError
end
