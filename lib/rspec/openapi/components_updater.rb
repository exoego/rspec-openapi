require_relative 'hash_helper'

class << RSpec::OpenAPI::ComponentsUpdater = Object.new
  # @param [Hash] base
  # @param [Hash] fresh
  def update!(base, fresh)
    return if (base_schemas = base.dig('components', 'schemas')).nil?

    # Top-level schema: Used as the body of request or response
    top_level_refs = paths_to_top_level_refs(base)
    fresh_schemas = build_fresh_schemas(top_level_refs, base, fresh)

    # Clear out all properties before merge.
    # The properties using $ref are preserved since those are hand-crafted by user.
    fresh_schemas.keys.each do |schema_name|
      clear_properties_except_refs(base_schemas[schema_name])
    end
    RSpec::OpenAPI::SchemaMerger.merge!(base_schemas, fresh_schemas)
  end

  private

  def clear_properties_except_refs(obj)
    obj.each do |field_name, field_values|
      if field_name == 'properties'
        obj[field_name] = field_values.select do |key, value|
          value['$ref'] || value['type'] == 'object'
        end
      elsif field_values.is_a?(Hash)
        clear_properties_except_refs(field_values)
      end
    end
  end

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
end
