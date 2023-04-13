# frozen_string_literal: true

require_relative 'hash_helper'

class << RSpec::OpenAPI::ComponentsUpdater = Object.new
  # @param [Hash] base
  # @param [Hash] fresh
  def update!(base, fresh)
    # Top-level schema: Used as the body of request or response
    top_level_refs = paths_to_top_level_refs(base)
    return if top_level_refs.empty?

    fresh_schemas = build_fresh_schemas(top_level_refs, base, fresh)

    # Nested schema: References in Top-level schemas. May contain some top-level schema.
    generated_schema_names = fresh_schemas.keys
    nested_refs = find_non_top_level_nested_refs(base, generated_schema_names)
    nested_refs.each do |paths|
      # Slice between the parent name and the element before "$ref"
      # ["components", "schema", "Table", "properties", "database",                       "$ref"]
      #  0             1         2 ^....................^
      # ["components", "schema", "Table", "properties", "columns", "items",               "$ref"]
      #  0             1         2 ^...............................^
      # ["components", "schema", "Table", "properties", "owner", "properties", "company", "$ref"]
      #  0             1         2 ^...........................................^
      needle = paths.slice(2, paths.size - 3)
      nested_schema = fresh_schemas.dig(*needle)

      # Skip if the property using $ref is not found in the parent schema. The property may be removed.
      next if nested_schema.nil?

      schema_name = base.dig(*paths)&.gsub('#/components/schemas/', '')
      fresh_schemas[schema_name] ||= {}
      RSpec::OpenAPI::SchemaMerger.merge!(fresh_schemas[schema_name], nested_schema)
    end

    RSpec::OpenAPI::SchemaMerger.merge!(base, { 'components' => { 'schemas' => fresh_schemas } })
    RSpec::OpenAPI::SchemaCleaner.cleanup_components_schemas!(base, { 'components' => { 'schemas' => fresh_schemas } })
  end

  private

  def build_fresh_schemas(references, base, fresh)
    references.inject({}) do |acc, paths|
      ref_link = dig_schema(base, paths)['$ref']
      schema_name = ref_link.gsub('#/components/schemas/', '')
      schema_body = dig_schema(fresh, paths)
      RSpec::OpenAPI::SchemaMerger.merge!(acc, { schema_name => schema_body })
    end
  end

  def dig_schema(obj, paths)
    obj.dig(*paths, 'schema', 'items') || obj.dig(*paths, 'schema')
  end

  def paths_to_top_level_refs(base)
    request_bodies = RSpec::OpenAPI::HashHelper.matched_paths(base, 'paths.*.*.requestBody.content.application/json')
    responses = RSpec::OpenAPI::HashHelper.matched_paths(base, 'paths.*.*.responses.*.content.application/json')
    (request_bodies + responses).select do |paths|
      dig_schema(base, paths)&.dig('$ref')&.start_with?('#/components/schemas/')
    end
  end

  def find_non_top_level_nested_refs(base, generated_names)
    nested_refs = [
      *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, 'components.schemas', 'properties.*.$ref'),
      *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, 'components.schemas', 'properties.*.items.$ref'),
    ]
    # Reject already-generated schemas to reduce unnecessary loop
    nested_refs.reject do |paths|
      ref_link = base.dig(*paths)
      schema_name = ref_link.gsub('#/components/schemas/', '')
      generated_names.include?(schema_name)
    end
  end
end
