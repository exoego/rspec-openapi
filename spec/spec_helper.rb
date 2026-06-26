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
    [out, err, status]
  end

  # Run inside the repo with the gem bundle, asserting the run succeeds.
  def run_tests(*args, command:, openapi: false, output: :yaml, openapi_version: nil)
    within_test_run(*args, command: command, openapi: openapi, output: output,
                           openapi_version: openapi_version,) { |argv| assert_run(*argv) }
  end

  # Same as run_tests, but returns [out, err, status] without asserting success,
  # so negative cases can assert on a run that is expected to abort.
  def capture_tests(*args, command:, openapi: false, output: :yaml, openapi_version: nil)
    within_test_run(*args, command: command, openapi: openapi, output: output,
                           openapi_version: openapi_version,) { |argv| Open3.capture3(*argv) }
  end

  def rspec(*args, openapi: false, output: :yaml, openapi_version: nil)
    run_tests(*args, command: 'scripts/rspec_with_simplecov', openapi: openapi, output: output,
                     openapi_version: openapi_version,)
  end

  def rspec_capture(*args, openapi: false, output: :yaml, openapi_version: nil)
    capture_tests(*args, command: 'scripts/rspec_with_simplecov', openapi: openapi, output: output,
                         openapi_version: openapi_version,)
  end

  def minitest(*args, openapi: false, output: :yaml, openapi_version: nil)
    run_tests(*args, command: 'ruby', openapi: openapi, output: output, openapi_version: openapi_version)
  end

  private

  def within_test_run(*args, command:, openapi:, output:, openapi_version:)
    env = {
      'OPENAPI' => ('1' if openapi),
      'OPENAPI_OUTPUT' => output.to_s,
      'OPENAPI_VERSION' => openapi_version,
    }.compact
    Bundler.public_send(Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env) do
      Dir.chdir(repo_root) do
        yield [env, 'bundle', 'exec', command, '-r./.simplecov_spawn', *args]
      end
    end
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
end
