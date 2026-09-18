# frozen_string_literal: true

require_relative 'hash_helper'

class << RSpec::OpenAPI::ComponentsUpdater = Object.new
  SCHEMA_REF_PREFIX = '#/components/schemas/'

  # @param [Hash] base
  # @param [Hash] fresh
  def update!(base, fresh)
    # Top-level schema: Used as the body of request or response
    top_level_refs = paths_to_top_level_refs(base)
    fresh_schemas = build_fresh_schemas(top_level_refs, base, fresh)

    # Nested schema: References in top-level schemas. May contain some top-level schema.
    # A parent to dig fresh data out of only exists once some top-level schema was found.
    apply_component_nested_refs!(fresh_schemas, base) unless top_level_refs.empty?

    # Nested schema: References inline in a request/response body, not inside a component.
    # Unlike the above, this doesn't depend on any top-level schema being found first.
    apply_inline_nested_refs!(fresh_schemas, base, fresh)

    return if fresh_schemas.empty?

    RSpec::OpenAPI::SchemaMerger.merge_normalized!(base, { components: { schemas: fresh_schemas } })
    RSpec::OpenAPI::SchemaCleaner.cleanup_components_schemas!(base, { components: { schemas: fresh_schemas } })
  end

  private

  def apply_component_nested_refs!(fresh_schemas, base)
    find_non_top_level_nested_refs(base, fresh_schemas.keys).each do |paths|
      # Slice between the parent name and the element before "$ref"
      # ["components", "schema", "Table", "properties", "database",                       "$ref"]
      #  0             1         2 ^....................^
      # ["components", "schema", "Table", "properties", "columns", "items",               "$ref"]
      #  0             1         2 ^...............................^
      # ["components", "schema", "Table", "properties", "owner", "properties", "company", "$ref"]
      #  0             1         2 ^...........................................^
      needle = paths.reject { |path| path.is_a?(Integer) || path == :oneOf }
      needle = needle.slice(2, needle.size - 3)
      nested_schema = fresh_schemas.dig(*needle)

      # Skip if the property using $ref is not found in the parent schema. The property may be removed.
      next if nested_schema.nil?

      merge_fresh_schema!(fresh_schemas, base, paths, nested_schema)
    end
  end

  # No promoted parent schema to dig from here, so pull the fresh data from the same
  # relative path in the raw document instead.
  def apply_inline_nested_refs!(fresh_schemas, base, fresh)
    find_inline_nested_refs(base, fresh_schemas.keys).each do |paths|
      nested_schema = fresh.dig(*paths[0..-2])
      next if nested_schema.nil?

      merge_fresh_schema!(fresh_schemas, base, paths, nested_schema)
    end
  end

  def merge_fresh_schema!(fresh_schemas, base, paths, nested_schema)
    schema_name = extract_schema_name(base.dig(*paths)).to_sym
    fresh_schemas[schema_name] ||= {}
    RSpec::OpenAPI::SchemaMerger.merge_normalized!(fresh_schemas[schema_name], nested_schema)
  end

  def build_fresh_schemas(references, base, fresh)
    references.inject({}) do |acc, paths|
      ref_link = dig_schema(base, paths)[:$ref]
      schema_name = extract_schema_name(ref_link)
      schema_body = dig_schema(fresh, paths.grep_v(Integer))

      RSpec::OpenAPI::SchemaMerger.merge_normalized!(acc, { schema_name => schema_body })
    end
  end

  def dig_schema(obj, paths)
    # Response code can be an integer
    paths = paths.map { |path| path.is_a?(Integer) ? path : path.to_sym }
    item_schema = obj.dig(*paths, :schema, :items)
    object_schema = obj.dig(*paths, :schema)
    one_of_schema = obj.dig(*paths.take(paths.size - 1), :schema, :oneOf, paths.last)

    item_schema || object_schema || one_of_schema
  end

  def paths_to_top_level_refs(base)
    request_bodies = RSpec::OpenAPI::HashHelper.matched_paths(base, 'paths.*.*.requestBody.content.application/json')
    responses = RSpec::OpenAPI::HashHelper.matched_paths(base, 'paths.*.*.responses.*.content.application/json')
    (request_bodies + responses).flat_map do |paths|
      object_paths = find_object_refs(base, paths)
      one_of_paths = find_one_of_refs(base, paths)

      object_paths || one_of_paths || []
    end
  end

  def find_non_top_level_nested_refs(base, generated_names)
    nested_refs = [
      *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, 'components.schemas', 'properties.*.$ref'),
      *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, 'components.schemas', 'properties.*.items.$ref'),
      *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, 'components.schemas', 'oneOf.*.$ref'),
    ]
    reject_already_generated_refs(nested_refs, base, generated_names)
  end

  # Like find_non_top_level_nested_refs, but for a $ref inside a schema that's inline
  # rather than itself a component, so it's not reachable by walking components.schemas.
  def find_inline_nested_refs(base, generated_names)
    roots = [
      'paths.*.*.requestBody.content.application/json.schema',
      'paths.*.*.responses.*.content.application/json.schema',
    ]
    nested_refs = roots.flat_map do |root|
      [
        *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, root, 'properties.*.$ref'),
        *RSpec::OpenAPI::HashHelper.matched_paths_deeply_nested(base, root, 'properties.*.items.$ref'),
      ]
    end
    reject_already_generated_refs(nested_refs, base, generated_names)
  end

  def reject_already_generated_refs(nested_refs, base, generated_names)
    nested_refs.reject do |paths|
      ref_link = base.dig(*paths)
      schema_name = extract_schema_name(ref_link)
      generated_names.include?(schema_name)
    end
  end

  def find_one_of_refs(base, paths)
    one_of = dig_schema(base, paths)&.dig(:oneOf)
    return unless one_of

    one_of.each_with_index.filter_map do |schema, index|
      paths + [index] if schema_ref?(schema&.dig(:$ref))
    end
  end

  def find_object_refs(base, paths)
    [paths] if schema_ref?(dig_schema(base, paths)&.dig(:$ref))
  end

  # Only ever given the value at a path ending in $ref, which is the link itself.
  def extract_schema_name(ref_link)
    ref_link.delete_prefix(SCHEMA_REF_PREFIX)
  end

  def schema_ref?(ref_link)
    ref_link&.start_with?(SCHEMA_REF_PREFIX)
  end
end
