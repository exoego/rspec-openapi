# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

# Collects records across processes when the test framework forks parallel
# workers, like Rails' `parallelize`. Records accumulate in each worker's own
# memory, so without this the main process would write the schema from an empty
# set. Each worker dumps its records to a shared directory on exit, and the
# main process merges every dump back in before recording results.
module RSpec::OpenAPI::ParallelRecords
  # The pid of the process that loaded this gem. Forked workers inherit the
  # constant, which is how they know they are not the main process.
  MAIN_PID = Process.pid

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

      FileUtils.mkdir_p(dump_dir)
      # path_records has a default proc, which Marshal refuses to dump.
      plain = RSpec::OpenAPI.path_records.to_h { |path, records| [path, records] }
      File.binwrite(File.join(dump_dir, "#{Process.pid}.dump"), Marshal.dump(plain))
    end

    def merge!
      Dir.glob(File.join(dump_dir, '*.dump')).sort.each do |file|
        # Dumps are same-run files this module wrote itself.
        records_by_path = Marshal.load(File.binread(file)) # rubocop:disable Security/MarshalLoad
        records_by_path.each do |path, records|
          RSpec::OpenAPI.path_records[path].concat(records)
        end
      end
    ensure
      FileUtils.rm_rf(dump_dir)
    end

    private

    # Keyed by the main process pid so concurrent runs on one machine cannot
    # read each other's dumps.
    def dump_dir
      File.join(Dir.tmpdir, "rspec-openapi-records-#{MAIN_PID}")
    end
  end
end
