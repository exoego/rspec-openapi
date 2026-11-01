# frozen_string_literal: true

# For Ruby 3.0+
require 'set'

require_relative 'hash_helper'

class << RSpec::OpenAPI::SchemaCleaner = Object.new
  # Cleanup the properties, of component schemas, that exists in the base but not in the spec.
  #
  # @param [Hash] base
  # @param [Hash] spec
  def cleanup_components_schemas!(base, spec)
    cleanup_hash!(base, spec, 'components.schemas.*')
    cleanup_hash!(base, spec, 'components.schemas.*.properties.*')
    cleanup_one_of_properties!(base, spec, 'components.schemas.*')
  end

  # The request and response bodies, where most of the cleanup happens.
  MEDIA_TYPE_SELECTORS = [
    'paths.*.*.requestBody.content.application/json',
    'paths.*.*.responses.*.content.application/json',
  ].freeze

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
    cleanup_array!(base, spec, 'paths.*.*.parameters', [:name, :in])

    # cleanup request and response bodies, each walked down to once
    MEDIA_TYPE_SELECTORS.each do |selector|
      RSpec::OpenAPI::HashHelper.each_matched(base, spec, selector) do |_parent, _key, media_type, fresh|
        cleanup_media_type!(media_type, fresh)
      end
    end

    # A full run decides readOnly anew, so a property no request sends any
    # more stops being held at false.
    RSpec::OpenAPI::HashHelper.each_schema(base.dig(:components, :schemas)) { |schema| delete_false_read_only!(schema) }

    base
  end

  def cleanup_conflicting_security_parameters!(base)
    security_schemes = base.dig(:components, :securitySchemes) || {}

    return if security_schemes.empty?

    each_operation(base) do |operation|
      security_schemes.each do |security_scheme_name, security_scheme|
        remove_parameters_conflicting_with_security_scheme!(operation, security_scheme, security_scheme_name)
      end
    end
  end

  # One walk over the schemas once the components are updated, which also drops
  # the fields the builder left for the merge. `readOnly: false` is how a
  # request says it sends a candidate property. A component shared by a request
  # and a response keeps it, or a later partial run that sees only the response
  # would flip it back to true. Inline under paths each side has its own
  # schema, so there it says nothing.
  def cleanup_schemas!(base)
    RSpec::OpenAPI::HashHelper.each_schema(base.dig(:components, :schemas)) do |schema|
      delete_temporary_fields!(schema)
      delete_empty_required!(schema)
    end
    RSpec::OpenAPI::HashHelper.each_schema(base[:paths]) do |schema|
      delete_temporary_fields!(schema)
      delete_empty_required!(schema)
      delete_false_read_only!(schema)
    end
  end

  private

  # The description of a response whose example is not recorded is provisional,
  # so it stays only where no documented test set one.
  def delete_temporary_fields!(schema)
    schema.delete(:_example_key)
    schema.delete(:_example_summary)
    schema.delete(:_example_name)
    return unless (fallback = schema.delete(:_fallback_description))

    schema[:description] ||= fallback
  end

  # A recorded example is data, so a field in it named `required` stays however
  # it is shaped. An empty `required` must not be present.
  def delete_empty_required!(schema)
    schema.delete(:required) if schema.key?(:properties) && schema[:required] && schema[:required].empty?
  end

  def delete_false_read_only!(schema)
    schema.delete(:readOnly) if schema[:readOnly] == false
  end

  # The selectors are relative to the media type. A media type the spec does
  # not hold has no fresh counterpart, and all of its entries are stale.
  def cleanup_media_type!(media_type, fresh)
    cleanup_hash!(media_type, fresh, 'schema.properties.*')
    cleanup_hash!(media_type, fresh, 'example.*')
    cleanup_hash!(media_type, fresh, 'examples.*')

    # cleanup properties of each variant once a body became a oneOf
    cleanup_one_of_properties!(media_type, fresh, 'schema')
  end

  # Security sits on operations, the hashes under a path item: a non-standard
  # method is still inline here and only moves under additionalOperations later.
  def each_operation(base)
    base[:paths].each_value do |path_item|
      next unless path_item.is_a?(Hash)

      path_item.each_value { |operation| yield operation if operation.is_a?(Hash) }
    end
  end

  def remove_parameters_conflicting_with_security_scheme!(path_definition, security_scheme, security_scheme_name)
    security = path_definition[:security]
    return if !security || security.empty?
    return unless path_definition[:parameters]
    return unless security[0].keys.include?(security_scheme_name)

    path_definition[:parameters].reject! do |parameter|
      parameter[:in] == security_scheme[:in] && # same location (ie. header)
        parameter[:name] == security_scheme[:name] # same name (ie. AUTHORIZATION)
    end
    path_definition.delete(:parameters) if path_definition[:parameters].empty?
  end

  def cleanup_array!(base, spec, selector, fields_for_identity)
    identity = ->(obj) { fields_for_identity.map { |field| obj[field] } }

    RSpec::OpenAPI::HashHelper.each_matched(base, spec, selector) do |_parent, _key, target_array, spec_array|
      next unless target_array.is_a?(Array) && spec_array.is_a?(Array)

      spec_identities = Set.new(spec_array.map(&identity))
      target_array.select! { |e| spec_identities.include?(identity.call(e)) }
      target_array.sort_by! { |param| identity.call(param).join('-') }
      # Keep the last duplicate to produce the result stably
      deduplicated = target_array.reverse.uniq(&identity).reverse
      target_array.replace(deduplicated)
    end
    base
  end

  def cleanup_one_of_properties!(base, spec, selector)
    RSpec::OpenAPI::HashHelper.each_matched(base, spec, selector) do |_parent, _key, schema, fresh|
      next unless schema.is_a?(Hash) && fresh.is_a?(Hash)

      variants = schema[:oneOf]
      next unless variants.is_a?(Array)

      variants.each { |variant| cleanup_variant_properties!(variant, variants, fresh) }
    end
    base
  end

  # Variants are matched by type, since the spec may hold one of them as a bare
  # schema or in another order. Two variants of one type can not be told apart
  # that way, so those stay as they are, like a variant of a type the spec does
  # not hold.
  def cleanup_variant_properties!(variant, variants, fresh)
    return unless variant.is_a?(Hash) && variant[:properties].is_a?(Hash)
    return unless variants.one? { |other| other.is_a?(Hash) && other[:type] == variant[:type] }

    counterpart = RSpec::OpenAPI::HashHelper.variant_of_type(fresh, variant[:type])
    return unless counterpart

    variant[:properties].delete_if { |name, _| counterpart.dig(:properties, name).nil? }
  end

  # The stale entries are deleted after the walk, which iterates their parents.
  def cleanup_hash!(base, spec, selector)
    stale = nil
    RSpec::OpenAPI::HashHelper.each_matched(base, spec, selector) do |parent, key, value, counterpart|
      (stale ||= []) << [parent, key] if !value.nil? && counterpart.nil?
    end
    stale&.each { |parent, key| parent.delete(key) }
    base
  end
end
