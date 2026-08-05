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
  # Options shape the spawned run's environment; see within_test_run.
  def run_tests(*args, command:, **options)
    within_test_run(*args, command: command, **options) { |argv| assert_run(*argv) }
  end

  # Same as run_tests, but returns [out, err, status] without asserting success,
  # so negative cases can assert on a run that is expected to abort.
  def capture_tests(*args, command:, **options)
    within_test_run(*args, command: command, **options) { |argv| Open3.capture3(*argv) }
  end

  def rspec(*args, **options)
    run_tests(*args, command: 'scripts/rspec_with_simplecov', **options)
  end

  def rspec_capture(*args, **options)
    capture_tests(*args, command: 'scripts/rspec_with_simplecov', **options)
  end

  def minitest(*args, **options)
    run_tests(*args, command: 'ruby', **options)
  end

  private

  # @param options [Hash] :openapi enables generation, :output picks yaml/json/both,
  #   :openapi_version pins the document version, :debug turns on rspec-openapi's
  #   own diagnostics. All of them are read while the child boots, which is why
  #   they travel as environment rather than as configuration in the spec.
  def within_test_run(*args, command:, **options)
    env = {
      'OPENAPI' => ('1' if options[:openapi]),
      'OPENAPI_OUTPUT' => options.fetch(:output, :yaml).to_s,
      'OPENAPI_VERSION' => options[:openapi_version],
      'DEBUG' => ('1' if options[:debug]),
    }.compact
    Bundler.public_send(Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env) do
      Dir.chdir(repo_root) do
        yield [env, 'bundle', 'exec', command, '-r./.simplecov_spawn', *args]
      end
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure.
  # scripts/parallel_rspec points each worker at its own file, because RSpec
  # rewrites this file wholesale and parallel workers would clobber each other.
  config.example_status_persistence_file_path = ENV.fetch('RSPEC_STATUS_FILE', '.rspec_status')

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
end
