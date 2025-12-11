# frozen_string_literal: true

class << RSpec::OpenAPI::SchemaBuilder = Object.new
  # @param [RSpec::OpenAPI::Record] record
  # @return [Hash]
  def build(record)
    response = {
      description: record.description,
    }

    response_headers = build_response_headers(record)
    response[:headers] = response_headers unless response_headers.empty?

    if record.response_body
      disposition = normalize_content_disposition(record.response_content_disposition)

      has_content = !normalize_content_type(record.response_content_type).nil?
      if has_content
        response[:content] = {
          normalize_content_type(record.response_content_type) => {
            schema: build_property(record.response_body, disposition: disposition, record: record),
            example: response_example(record, disposition: disposition),
          }.compact,
        }
      end
    end

    http_method = record.http_method.downcase
    {
      paths: {
        normalize_path(record.path) => {
          http_method => {
            summary: record.summary,
            tags: record.tags,
            operationId: record.operation_id,
            security: record.security,
            deprecated: record.deprecated ? true : nil,
            parameters: build_parameters(record),
            requestBody: include_nil_request_body?(http_method) ? nil : build_request_body(record),
            responses: {
              record.status.to_s => response,
            },
          }.compact,
        },
      },
    }
  end

  private

  def include_nil_request_body?(http_method)
    %w[delete get].include?(http_method)
  end

  def enrich_with_required_keys(obj)
    obj[:required] = obj[:properties]&.keys || []
    obj
  end

  def response_example(record, disposition:)
    return nil if !example_enabled? || disposition

    record.response_body
  end

  def example_enabled?
    RSpec::OpenAPI.enable_example
  end

  def build_parameters(record)
    path_params = record.path_params.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'path',
        required: true,
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    query_params = record.query_params.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'query',
        required: record.required_request_params.include?(key),
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    header_params = record.request_headers.map do |key, value|
      {
        name: build_parameter_name(key, value),
        in: 'header',
        required: true,
        schema: build_property(try_cast(value), key: key, record: record),
        example: (try_cast(value) if example_enabled?),
      }.compact
    end

    parameters = path_params + query_params + header_params

    return nil if parameters.empty?

    parameters
  end

  def build_response_headers(record)
    headers = {}

    record.response_headers.each do |key, value|
      headers[key] = {
        schema: build_property(try_cast(value), key: key, record: record),
      }.compact
    end

    headers
  end

  def build_parameter_name(key, value)
    key = key.to_s
    if value.is_a?(Hash) && (value_keys = value.keys).size == 1
      value_key = value_keys.first
      build_parameter_name("#{key}[#{value_key}]", value[value_key])
    else
      key
    end
  end

  def build_request_body(record)
    return nil if record.request_content_type.nil?
    return nil if record.status >= 400

    {
      content: {
        normalize_content_type(record.request_content_type) => {
          schema: build_property(record.request_params, record: record),
          example: (build_example(record.request_params) if example_enabled?),
        }.compact,
      },
    }
  end

  def build_property(value, disposition: nil, key: nil, record: nil)
    format = disposition ? 'binary' : infer_format(key, record)

    property = build_type(value, format: format)

    case value
    when Array
      property[:items] = if value.empty?
                           {} # unknown
                         else
                           build_array_items_schema(value, record: record)
                         end
    when Hash
      property[:properties] = {}.tap do |properties|
        value.each do |key, v|
          properties[key] = build_property(v, record: record, key: key)
        end
      end
      property = enrich_with_required_keys(property)
    end
    property
  end

  def build_type(value, format: nil)
    return { type: 'string', format: format } if format

    case value
    when String
      { type: 'string' }
    when Integer
      { type: 'integer' }
    when Float
      { type: 'number', format: 'float' }
    when TrueClass, FalseClass
      { type: 'boolean' }
    when Array
      { type: 'array' }
    when Hash
      { type: 'object' }
    when ActionDispatch::Http::UploadedFile
      { type: 'string', format: 'binary' }
    when NilClass
      { nullable: true }
    else
      raise NotImplementedError, "type detection is not implemented for: #{value.inspect}"
    end
  end

  def infer_format(key, record)
    return nil if !key || !record || !record.formats

    record.formats[key]
  end

  # Convert an always-String param to an appropriate type
  def try_cast(value)
    Integer(value)
  rescue TypeError, ArgumentError
    value
  end

  def build_example(value)
    return nil if value.nil?

    value = value.dup
    adjust_params(value)
  end

  def adjust_params(value)
    value.each do |key, v|
      case v
      when ActionDispatch::Http::UploadedFile
        value[key] = v.original_filename
      when Hash
        adjust_params(v)
      when Array
        result = v.map do |item|
          case item
          when ActionDispatch::Http::UploadedFile
            item.original_filename
          when Hash
            adjust_params(item)
          else
            item
          end
        end
        value[key] = result
      end
    end
  end

  def normalize_path(path)
    path.gsub(%r{/:([^:/]+)}, '/{\1}')
  end

  def normalize_content_type(content_type)
    content_type&.sub(/;.+\z/, '')
  end

  def normalize_content_disposition(content_disposition)
    content_disposition&.sub(/;.+\z/, '')
  end

  def build_array_items_schema(array, record: nil)
    return {} if array.empty?
    return build_property(array.first, record: record) if array.size == 1
    return build_property(array.first, record: record) unless array.all? { |item| item.is_a?(Hash) }

    all_schemas = array.map { |item| build_property(item, record: record) }
    merged_schema = all_schemas.first.dup
    merged_schema[:properties] = {}

    all_keys = all_schemas.flat_map { |s| s[:properties]&.keys || [] }.uniq

    all_keys.each do |key|
      all_property_schemas = all_schemas.map { |s| s[:properties]&.[](key) }

      nullable_only_schemas = all_property_schemas.select { |p| p && p.keys == [:nullable] }
      property_variations = all_property_schemas.select { |p| p && p.keys != [:nullable] }

      has_nullable = all_property_schemas.any?(&:nil?) || nullable_only_schemas.any?

      next if property_variations.empty? && !has_nullable

      if property_variations.empty? && has_nullable
        merged_schema[:properties][key] = { nullable: true }
      elsif property_variations.size == 1
        merged_schema[:properties][key] = property_variations.first.dup
      else
        has_one_of = property_variations.any? { |p| p.key?(:oneOf) }

        if has_one_of
          all_options = []
          property_variations.each do |prop|
            clean_prop = prop.reject { |k, _| k == :nullable }
            if clean_prop.key?(:oneOf)
              all_options.concat(clean_prop[:oneOf])
            else
              all_options << clean_prop unless clean_prop.empty?
            end
          end

          all_options.uniq!
          merged_schema[:properties][key] = { oneOf: all_options }
        else
          unique_types = property_variations.map { |p| p[:type] }.compact.uniq

          if unique_types.size > 1
            unique_props = property_variations.map { |p| p.reject { |k, _| k == :nullable } }.uniq
            merged_schema[:properties][key] = { oneOf: unique_props }
          else
            case unique_types.first
            when 'array'
              merged_schema[:properties][key] = { type: 'array' }
              items_variations = property_variations.map { |p| p[:items] }.compact
              merged_schema[:properties][key][:items] = build_merged_schema_from_variations(items_variations)
            when 'object'
              merged_schema[:properties][key] = build_merged_schema_from_variations(property_variations)
            else
              merged_schema[:properties][key] = property_variations.first.dup
            end
          end
        end
      end

      merged_schema[:properties][key][:nullable] = true if has_nullable && merged_schema[:properties][key].is_a?(Hash)
    end

    all_required_sets = all_schemas.map { |s| s[:required] || [] }
    merged_schema[:required] = all_required_sets.reduce(:&) || []

    merged_schema
  end

  def build_merged_schema_from_variations(variations)
    return {} if variations.empty?
    return variations.first if variations.size == 1

    types = variations.map { |v| v[:type] }.compact.uniq

    if types.size == 1 && types.first == 'object'
      merged = { type: 'object', properties: {} }
      all_keys = variations.flat_map { |v| v[:properties]&.keys || [] }.uniq

      all_keys.each do |key|
        all_prop_variations = variations.map { |v| v[:properties]&.[](key) }

        nullable_only = all_prop_variations.select { |p| p && p.keys == [:nullable] }
        prop_variations = all_prop_variations.select { |p| p && p.keys != [:nullable] }.compact

        has_nullable = all_prop_variations.any?(&:nil?) || nullable_only.any?

        if prop_variations.empty? && has_nullable
          merged[:properties][key] = { nullable: true }
        elsif prop_variations.size == 1
          merged[:properties][key] = prop_variations.first.dup
          merged[:properties][key][:nullable] = true if has_nullable
        elsif prop_variations.size > 1
          prop_types = prop_variations.map { |p| p[:type] }.compact.uniq
          has_one_of = prop_variations.any? { |p| p.key?(:oneOf) }

          if has_one_of
            all_options = []
            prop_variations.each do |prop|
              clean_prop = prop.reject { |k, _| k == :nullable }
              if clean_prop.key?(:oneOf)
                all_options.concat(clean_prop[:oneOf])
              else
                all_options << clean_prop unless clean_prop.empty?
              end
            end
            all_options.uniq!
            merged[:properties][key] = { oneOf: all_options }
          elsif prop_types.size == 1
            # Only recursively merge if it's an object type
            merged[:properties][key] = if prop_types.first == 'object'
                                         build_merged_schema_from_variations(prop_variations)
                                       else
                                         prop_variations.first.dup
                                       end
          else
            unique_props = prop_variations.map { |p| p.reject { |k, _| k == :nullable } }.uniq
            merged[:properties][key] = { oneOf: unique_props }
          end

          merged[:properties][key][:nullable] = true if has_nullable || prop_variations.size < variations.size
        end
      end

      all_required = variations.map { |v| v[:required] || [] }
      merged[:required] = all_required.reduce(:&) || []

      merged
    else
      variations.first
    end
  end
end
