# frozen_string_literal: true

require 'open3'
require 'super_diff/rspec'

module SpecHelper
  def repo_root
    File.expand_path('..', __dir__)
  end

  def assert_run(*args)
    out, err, status = Open3.capture3(*args)
    expect(status.success?).to eq(true), "stdout:\n#{out}\nstderr:\n#{err}"
  end

  def run_tests(*args, command:, openapi: false, output: :yaml)
    env = {
      'OPENAPI' => ('1' if openapi),
      'OPENAPI_OUTPUT' => output.to_s,
    }.compact
    Bundler.public_send(Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env) do
      Dir.chdir(repo_root) do
        assert_run env, 'bundle', 'exec', command, '-r./.simplecov_spawn', *args
      end
    end
  end

  def rspec(*args, openapi: false, output: :yaml)
    run_tests(*args, command: 'scripts/rspec_with_simplecov', openapi: openapi, output: output)
  end

  def minitest(*args, openapi: false, output: :yaml)
    run_tests(*args, command: 'ruby', openapi: openapi, output: output)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
  config.diff_elision_maximum = 3
end
