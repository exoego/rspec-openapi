# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'tmpdir'
require 'yaml'

# Collects records across processes when the test framework forks parallel
# workers, like Rails' `parallelize`. Records accumulate in each worker's own
# memory, so without this the main process would write the schema from an empty
# set. Each worker dumps its records to a shared directory on exit, and the
# main process merges every dump back in before recording results.
#
# The dumps go through YAML.safe_load with an allowlist rather than Marshal,
# so reading them cannot instantiate arbitrary objects even if the directory
# were tampered with.
module RSpec::OpenAPI::ParallelRecords
  # The pid of the process that loaded this gem. Forked workers inherit the
  # constant, which is how they know they are not the main process.
  MAIN_PID = Process.pid

  # Unpredictable per-run token. Workers inherit it across fork, while other
  # local users cannot guess it to pre-create or plant files in the dump
  # directory, which lives in the world-writable system tmpdir.
  RUN_ID = SecureRandom.hex(16)

  class << self
    def worker?
      Process.pid != MAIN_PID
    end

    # Called when a worker records an example. Registered lazily from inside
    # the worker because an at_exit inherited from the main process has already
    # run there by the time workers fork: minitest executes the whole suite
    # from an at_exit hook, so handlers the gem registered at load time are
    # popped before any fork happens.
    def schedule_dump!
      return if @dump_scheduled || !worker?

      @dump_scheduled = true
      at_exit { dump! }
    end

    def dump!
      return if RSpec::OpenAPI.path_records.empty?

      FileUtils.mkdir_p(dump_dir, mode: 0o700)
      File.write(File.join(dump_dir, "#{Process.pid}.yaml"), YAML.dump(RSpec::OpenAPI.path_records))
    end

    def merge!
      Dir.glob(File.join(dump_dir, '*.yaml')).sort.each do |file|
        records_by_path = YAML.safe_load(File.read(file), permitted_classes: permitted_classes, aliases: true)
        records_by_path.each do |path, records|
          RSpec::OpenAPI.path_records[path].concat(records)
        end
      end
    ensure
      FileUtils.rm_rf(dump_dir)
    end

    private

    def dump_dir
      File.join(Dir.tmpdir, "rspec-openapi-records-#{RUN_ID}")
    end

    # Built lazily because ActiveSupport is not loaded in every setup. Rails
    # request objects hand back HashWithIndifferentAccess for parameters.
    def permitted_classes
      classes = [Symbol, RSpec::OpenAPI::Record]
      classes << ActiveSupport::HashWithIndifferentAccess if defined?(ActiveSupport::HashWithIndifferentAccess)
      classes
    end
  end
end
