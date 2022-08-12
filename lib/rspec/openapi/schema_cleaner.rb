# For Ruby 3.0+
require 'set'

require_relative 'hash_helper'

class << RSpec::OpenAPI::SchemaCleaner = Object.new
  # Cleanup the properties, of component schemas, that exists in the base but not in the spec.
  #
  # @param [Hash] base
  # @param [Hash] spec
  def cleanup_components_schemas!(base, spec)
    cleanup_hash!(base, spec, 'components.schemas.*.properties.*')
  end

  # Cleanup specific elements that exists in the base but not in the spec
  #
  # @param [Hash] base
  # @param [Hash] spec
  def cleanup!(base, spec)
    # cleanup URLs
    cleanup_hash!(base, spec, 'paths.*')

    # cleanup HTTP methods
    cleanup_hash!(base, spec, 'paths.*.*')

    # cleanup parameters
    cleanup_array!(base, spec, 'paths.*.*.parameters', %w[name in])

    # cleanup requestBody
    cleanup_hash!(base, spec, 'paths.*.*.requestBody.content.application/json.schema.properties.*')
    cleanup_hash!(base, spec, 'paths.*.*.requestBody.content.application/json.example.*')

    # cleanup responses
    cleanup_hash!(base, spec, 'paths.*.*.responses.*.content.application/json.schema.properties.*')
    cleanup_hash!(base, spec, 'paths.*.*.responses.*.content.application/json.example.*')
    base
  end

  private

  def cleanup_array!(base, spec, selector, fields_for_identity = [])
    marshal = lambda do |obj|
      Marshal.dump(slice(obj, fields_for_identity))
    end

    RSpec::OpenAPI::HashHelper::matched_paths(base, selector).each do |paths|
      target_array = base.dig(*paths)
      spec_array = spec.dig(*paths)
      unless target_array.is_a?(Array) && spec_array.is_a?(Array)
        next
      end
      spec_identities = Set.new(spec_array.map(&marshal))
      target_array.select! { |e| spec_identities.include?(marshal.call(e)) }
      target_array.sort_by! { |param| fields_for_identity.map {|f| param[f] }.join('-') }
      # Keep the last duplicate to produce the result stably
      deduplicated = target_array.reverse.uniq { |param| slice(param, fields_for_identity) }.reverse
      target_array.replace(deduplicated)
    end
    base
  end

  def cleanup_hash!(base, spec, selector)
    RSpec::OpenAPI::HashHelper::matched_paths(base, selector).each do |paths|
      exist_in_base = !base.dig(*paths).nil?
      not_in_spec = spec.dig(*paths).nil?
      if exist_in_base && not_in_spec
        if paths.size == 1
          base.delete(paths.last)
        else
          parent_node = base.dig(*paths[0..-2])
          parent_node.delete(paths.last)
        end
      end
    end
    base
  end

  def slice(obj, fields_for_identity)
    if fields_for_identity.any?
      obj.slice(*fields_for_identity)
    else
      obj
    end
  end
end
