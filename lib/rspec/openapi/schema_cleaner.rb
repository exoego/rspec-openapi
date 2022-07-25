# For Ruby 3.0+
require 'set'

class << RSpec::OpenAPI::SchemaCleaner = Object.new
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

  def paths_to_all_fields(obj)
    case obj
    when Hash
      obj.each.flat_map do |k,v|
        k = k.to_s
        [[k]] + paths_to_all_fields(v).map { |x| [k, *x] }
      end
    else
      []
    end
  end

  def matched_paths(obj, selector)
    selector_parts = selector.split('.').map(&:to_s)
    selectors = paths_to_all_fields(obj).select do |key_parts|
      key_parts.size == selector_parts.size && key_parts.zip(selector_parts).all? do |kp, sp|
        kp == sp || (sp == '*' && kp != nil)
      end
    end
    selectors
  end

  def cleanup_array!(base, spec, selector, fields_for_identity = [])
    marshal = lambda do |obj|
      Marshal.dump(slice(obj, fields_for_identity))
    end

    matched_paths(base, selector).each do |paths|
      target_array = base.dig(*paths)
      spec_array = spec.dig(*paths)
      unless target_array.is_a?(Array) && spec_array.is_a?(Array)
        next
      end
      spec_identities = Set.new(spec_array.map(&marshal))
      target_array.select! { |e| spec_identities.include?(marshal.call(e)) }
      target_array
        .sort_by! { |param| [param['__marker'], *fields_for_identity.map {|f| param[f] }].join('-') }
        .each { |param| param.delete('__marker') }
      # Keep the last duplicate with largest __marker, to produce the result stably
      deduplicated = (target_array.reverse.uniq do |param|
        slice(param, fields_for_identity)
      end).reverse
      target_array.replace(deduplicated)
    end
    base
  end

  def cleanup_hash!(base, spec, selector)
    matched_paths(base, selector).each do |paths|
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

  private

  def slice(obj, fields_for_identity)
    if fields_for_identity.any?
      obj.slice(*fields_for_identity)
    else
      obj
    end
  end
end
