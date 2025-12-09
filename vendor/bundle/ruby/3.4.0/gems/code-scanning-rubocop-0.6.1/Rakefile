# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :generate_rules do
  require_relative "lib/code_scanning/rules_generator"

  begin
    output_file = "#{Time.now.strftime('%Y%m%d')}.sarif"
    puts "Cloning rubocop repository to read manuals"
    puts

    sh "git clone git@github.com:rubocop-hq/rubocop.git _tmp"

    gen = QHelpGenerator.new
    Dir["_tmp/manual/cops_*.md"].each do |f|
      gen.parse_file(f)
    end
    puts
    puts "Writing rules help sarif to '#{output_file}' file"
    puts
    File.write(output_file, gen.sarif_json)
  ensure
    sh "rm -rf _tmp"
  end
end

task default: :test
