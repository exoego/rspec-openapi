require_relative 'hash_helper'

class << RSpec::OpenAPI::ComponentsUpdater = Object.new
  # @param [Hash] base
  # @param [Hash] fresh
  def update!(base, fresh)
    return if (base_schemas = base.dig('components', 'schemas')).nil?

    # Top-level schema: Used as the body of request or response
    top_level_refs = paths_to_top_level_refs(base)
    fresh_schemas = build_fresh_schemas(top_level_refs, base, fresh)

    # Nested schema: References in Top-level schemas. May contain some top-level schema.
    nested_refs = RSpec::OpenAPI::HashHelper::matched_paths(base, 'components.schemas.*.properties.*.$ref')

    # We assume that super-deeply nested references are not common.
    # Loop counter may exhaust if some of referenced are not generated due to removal. No need to raise error.
    5.times.each do
      generated_schema_names = fresh_schemas.keys
      nested_refs = filter_non_generated_refs(nested_refs, base, generated_schema_names)

      # Complete if all the referenced schemas are generated.
      break if nested_refs.empty?

      nested_refs.each do |paths|
        parent_name = paths[-4]

        # Skip if parent schema is not generated yet. It may be generated on next iteration.
        next if fresh_schemas.dig(parent_name).nil?

        property_name = paths[-2]
        sub_schema = fresh_schemas.dig(parent_name, 'properties', property_name)

        # Skip if the property using $ref is not found in the parent schema. The property may be removed.
        next if sub_schema.nil?

        schema_name = base.dig(*paths)&.gsub('#/components/schemas/', '')
        fresh_schemas[schema_name] ||= {}
        RSpec::OpenAPI::SchemaMerger.merge!(fresh_schemas[schema_name], sub_schema)
      end
    end

    RSpec::OpenAPI::SchemaMerger.merge!(base_schemas, fresh_schemas)
    RSpec::OpenAPI::SchemaCleaner.cleanup_components_schemas!(base, { 'components' => { 'schemas' => fresh_schemas } })
  end

  private

  def build_fresh_schemas(references, base, fresh)
    references.inject({}) do |acc, paths|
      ref_link = dig_schema(base, paths).dig('$ref')
      schema_name = ref_link.gsub('#/components/schemas/', '')
      schema_body = dig_schema(fresh, paths)
      RSpec::OpenAPI::SchemaMerger.merge!(acc, { schema_name => schema_body })
    end
  end

  def dig_schema(obj, paths)
    obj.dig(*paths, 'schema', 'items') || obj.dig(*paths, 'schema')
  end

  def paths_to_top_level_refs(base)
    request_bodies = RSpec::OpenAPI::HashHelper::matched_paths(base, 'paths.*.*.requestBody.content.application/json')
    responses = RSpec::OpenAPI::HashHelper::matched_paths(base, 'paths.*.*.responses.*.content.application/json')
    (request_bodies + responses).select do |paths|
      dig_schema(base, paths)&.dig('$ref')&.start_with?('#/components/schemas/')
    end
  end

  def filter_non_generated_refs(nested_refs, base, generated_names)
    # Reject already-generated schemas to reduce unnecessary loop
    nested_refs.reject do |paths|
      ref_link = base.dig(*paths)
      schema_name = ref_link.gsub('#/components/schemas/', '')
      generated_names.include?(schema_name)
    end
  end
end
