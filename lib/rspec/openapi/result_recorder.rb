# frozen_string_literal: true

class RSpec::OpenAPI::ResultRecorder
  def initialize(path_records)
    @path_records = path_records
    @error_records = {}
  end

  def record_results!
    title = RSpec::OpenAPI.title
    @path_records.each do |path, records|
      RSpec::OpenAPI::SchemaFile.new(path).edit do |spec|
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
        RSpec::OpenAPI::SchemaCleaner.cleanup!(spec, new_from_zero)
        RSpec::OpenAPI::ComponentsUpdater.update!(spec, new_from_zero)
        RSpec::OpenAPI::SchemaCleaner.cleanup_empty_required_array!(spec)
        RSpec::OpenAPI::SchemaCleaner.sort_paths!(spec)
      end
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
end
