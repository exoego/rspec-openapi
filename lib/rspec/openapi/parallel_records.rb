# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'stringio'
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

  # Marks the stand-in a multipart upload leaves in a dump. The schema
  # builder only ever asks an upload for its class and metadata, never for
  # its content, so the file itself does not need to survive the trip.
  UPLOADED_FILE_MARKER = '__rspec_openapi_uploaded_file'

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
      encoded = RSpec::OpenAPI.path_records.transform_values do |records|
        records.map { |record| transform_record(record) { |value| encode(value) } }
      end
      File.write(File.join(dump_dir, "#{Process.pid}.yaml"), YAML.dump(encoded))
    end

    def merge!
      Dir.glob(File.join(dump_dir, '*.yaml')).sort.each do |file|
        records_by_path = YAML.safe_load(File.read(file), permitted_classes: permitted_classes, aliases: true)
        records_by_path.each do |path, records|
          decoded = records.map { |record| transform_record(record) { |value| decode(value) } }
          RSpec::OpenAPI.path_records[path].concat(decoded)
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

    def transform_record(record, &block)
      RSpec::OpenAPI::Record.new(**record.to_h.transform_values(&block))
    end

    # Uploads hold an open Tempfile, which no serializer can represent, so
    # dump their metadata instead.
    def encode(value)
      case value
      when Array then value.map { |item| encode(item) }
      when Hash then value.transform_values { |item| encode(item) }
      when defined?(ActionDispatch::Http::UploadedFile) && ActionDispatch::Http::UploadedFile
        { UPLOADED_FILE_MARKER => { 'filename' => value.original_filename, 'type' => value.content_type } }
      else value
      end
    end

    # Rebuilds a real UploadedFile so the schema builder's class checks match,
    # backed by an empty StringIO in place of the worker's Tempfile.
    def decode(value)
      return value unless value.is_a?(Array) || value.is_a?(Hash)
      return value.map { |item| decode(item) } if value.is_a?(Array)

      meta = value[UPLOADED_FILE_MARKER]
      if meta && value.size == 1 && defined?(ActionDispatch::Http::UploadedFile)
        ActionDispatch::Http::UploadedFile.new(tempfile: StringIO.new, filename: meta['filename'], type: meta['type'])
      else
        value.transform_values { |item| decode(item) }
      end
    end
  end
end
