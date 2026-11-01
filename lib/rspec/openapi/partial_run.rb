# frozen_string_literal: true

require 'set'

# Decides whether a run adds and updates the document without removing anything.
#
# A run over part of the suite cannot tell an endpoint that was removed from
# one whose spec did not run, so it removes nothing. Only a run over the whole
# suite does. RSpec::OpenAPI.partial_update forces either mode.
module RSpec::OpenAPI::PartialRun
  class << self
    # The spec file of an example that recorded a request. The run is partial
    # when a spec file next to one of these was left out.
    def record_file(path)
      recorded_files << path
    end

    def rspec?
      configured = RSpec::OpenAPI.partial_update
      return configured unless configured.nil?

      parallel_worker? || filtered? || files_left_out?
    end

    # Minitest tells nothing about the run, so only the option and the
    # parallel_tests marker count.
    def minitest?
      configured = RSpec::OpenAPI.partial_update
      configured == true || (configured.nil? && parallel_worker?)
    end

    # Printed when the run decided on its own, since the user may expect the
    # removals of a full run.
    def notice(partial)
      return unless partial && RSpec::OpenAPI.partial_update.nil? && recorded_files.any?

      'rspec-openapi: this run covered part of the suite, so nothing was removed from the document. ' \
        'Run all specs to remove what no longer exists.'
    end

    private

    def recorded_files
      @recorded_files ||= Set.new
    end

    # parallel_tests marks each worker with TEST_ENV_NUMBER, an empty string
    # for the first one. A worker sees part of the files, whichever files it
    # got, so the directory check below cannot tell it from a full run.
    def parallel_worker?
      ENV.key?('TEST_ENV_NUMBER')
    end

    # -e, --tag, a line number, --only-failures, and a `fit` once an example
    # carries it. An exclusion such as `--tag ~slow` does not narrow the run.
    def filtered?
      RSpec.configuration.inclusion_filter.rules.any?
    end

    # `rspec spec/requests/users_spec.rb` leaves out the other files of
    # spec/requests. `rspec spec/requests` and `rspec spec/requests/*_spec.rb`
    # do not, nor does a run that leaves out files of a directory that
    # recorded nothing.
    def files_left_out?
      running = RSpec.configuration.files_to_run
      recorded_files.map { |file| File.dirname(file) }.uniq.any? do |dir|
        (spec_files_in(dir) - running).any?
      end
    end

    # The spec files directly in dir, by the pattern and exclude pattern of
    # the run.
    def spec_files_in(dir)
      config = RSpec.configuration
      files = Dir[glob(dir, config.pattern)] - Dir[glob(dir, config.exclude_pattern)]
      files.map { |file| File.expand_path(file) }.select { |file| File.dirname(file) == dir }
    end

    # A pattern may list alternatives, which glob as a brace group like RSpec does.
    def glob(dir, pattern)
      File.join(dir, "{#{pattern.to_s.gsub(/\s*,\s*/, ',')}}")
    end
  end
end
