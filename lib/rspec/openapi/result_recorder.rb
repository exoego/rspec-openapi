# frozen_string_literal: true

class RSpec::OpenAPI::ResultRecorder
  # @param [Boolean] partial add and update without removing anything
  def initialize(path_records, partial: false)
    @path_records = path_records
    @partial = partial
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
      # The cleanup compares the document with one built from this run alone.
      # Without an existing document nothing can be stale, so the document is
      # that one and the records are merged once.
      new_from_zero = spec.empty? ? spec : {}
      # Normalize an existing file back to the internal form so merge/cleanup is
      # version-agnostic; cleanup_schema! re-applies the target form.
      RSpec::OpenAPI::NullableConverter.normalize!(spec)
      RSpec::OpenAPI::OperationConverter.normalize!(spec)
      schema = RSpec::OpenAPI::DefaultSchema.build(title)
      schema[:info].merge!(RSpec::OpenAPI.info)
      # SchemaFile#read already symbolized the document, so no merge here needs
      # to normalize it again.
      RSpec::OpenAPI::SchemaMerger.merge_normalized!(spec, schema)
      records.each do |record|
        record_schema = RSpec::OpenAPI::SchemaBuilder.build(record)
        RSpec::OpenAPI::SchemaMerger.merge_normalized!(spec, record_schema)
        RSpec::OpenAPI::SchemaMerger.merge_normalized!(new_from_zero, record_schema) unless new_from_zero.equal?(spec)
      rescue StandardError, NotImplementedError => e # e.g. SchemaBuilder raises a NotImplementedError
        @error_records[e] = record # Avoid failing the build
      end
      cleanup_schema!(new_from_zero, spec)
      execute_post_process_hook(primary, records, spec)
    end
  end

  def execute_post_process_hook(path, records, spec)
    return unless RSpec::OpenAPI.post_process_hook.is_a?(Proc)

    RSpec::OpenAPI.post_process_hook.call(path, records, spec)
    # The hook may add string keys beside the symbol ones, and the files are
    # written from the keys as they are. Folding them keeps one entry per name.
    spec.replace(RSpec::OpenAPI::KeyTransformer.symbolize(spec))
  end

  def cleanup_schema!(new_from_zero, spec)
    RSpec::OpenAPI::SchemaCleaner.cleanup_conflicting_security_parameters!(spec)
    if @partial
      RSpec::OpenAPI::SchemaCleaner.cleanup_temporary_fields!(spec)
    else
      RSpec::OpenAPI::SchemaCleaner.cleanup!(spec, new_from_zero)
    end
    RSpec::OpenAPI::ComponentsUpdater.update!(spec, new_from_zero, partial: @partial)
    RSpec::OpenAPI::SchemaCleaner.cleanup_false_read_only!(spec)
    RSpec::OpenAPI::SchemaCleaner.cleanup_empty_required_array!(spec)
    RSpec::OpenAPI::OperationConverter.to_additional_operations!(spec) if RSpec::OpenAPI.supports_additional_operations?
    RSpec::OpenAPI::SchemaSorter.deep_sort!(spec)
    RSpec::OpenAPI::NullableConverter.to_json_schema!(spec) if RSpec::OpenAPI.json_schema_based?
  end
end
