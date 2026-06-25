# frozen_string_literal: true

class RSpec::OpenAPI::ResultRecorder
  def initialize(path_records)
    @path_records = path_records
    @error_records = {}
  end

  def record_results!
    @path_records.each do |paths, records|
      # A single record set may target multiple output files (e.g. both YAML and
      # JSON). The first path is the canonical source we read/merge into; the rest
      # mirror the same built spec, each formatted by its own extension.
      primary, *mirrors = Array(paths)
      next if primary.nil?

      load_path_config(primary)
      built_spec = build_spec(primary, records)
      mirrors.each { |mirror_path| RSpec::OpenAPI::SchemaFile.new(mirror_path).write(built_spec) }
    end
  end

  def errors?
    @error_records.any?
  end

  def error_message
    <<~ERR_MSG
      RSpec::OpenAPI got errors building #{@error_records.size} requests

      #{@error_records.map { |e, record| "#{e.inspect}: #{record.inspect}" }.join("\n")}
    ERR_MSG
  end

  private

  # Look for a path-specific config file and run it.
  def load_path_config(path)
    config_file = File.join(File.dirname(path), RSpec::OpenAPI.config_filename)
    require config_file if File.exist?(config_file)
  rescue StandardError => e
    puts "WARNING: Unable to load #{config_file}: #{e}"
  end

  def build_spec(primary, records)
    title = records.first.title
    RSpec::OpenAPI::SchemaFile.new(primary).edit do |spec|
      schema = RSpec::OpenAPI::DefaultSchema.build(title)
      schema[:info].merge!(RSpec::OpenAPI.info)
      RSpec::OpenAPI::SchemaMerger.merge!(spec, schema)
      new_from_zero = {}
      records.each do |record|
        record_schema = RSpec::OpenAPI::SchemaBuilder.build(record)
        RSpec::OpenAPI::SchemaMerger.merge!(spec, record_schema)
        RSpec::OpenAPI::SchemaMerger.merge!(new_from_zero, record_schema)
      rescue StandardError, NotImplementedError => e # e.g. SchemaBuilder raises a NotImplementedError
        @error_records[e] = record # Avoid failing the build
      end
      cleanup_schema!(new_from_zero, spec)
      execute_post_process_hook(primary, records, spec)
    end
  end

  def execute_post_process_hook(path, records, spec)
    RSpec::OpenAPI.post_process_hook.call(path, records, spec) if RSpec::OpenAPI.post_process_hook.is_a?(Proc)
  end

  def cleanup_schema!(new_from_zero, spec)
    RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)
    RSpec::OpenAPI::SchemaCleaner.cleanup!(spec, new_from_zero)
    RSpec::OpenAPI::ComponentsUpdater.update!(spec, new_from_zero)
    RSpec::OpenAPI::SchemaCleaner.cleanup_empty_required_array!(spec)
    RSpec::OpenAPI::SchemaSorter.deep_sort!(spec)
  end
end
