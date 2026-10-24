# frozen_string_literal: true

class << RSpec::OpenAPI::KeyTransformer = Object.new
  # The hashes are rebuilt with each rather than to_h, which yields every
  # entry as a fresh pair array.
  def symbolize(value)
    case value
    when Hash
      result = {}
      value.each do |k, v|
        k = k.to_sym
        result[k] = k == :examples ? symbolize_examples(v) : symbolize(v)
      end
      result
    when Array
      value.map { |v| symbolize(v) }
    else
      value
    end
  end

  # `examples` is a map of named examples under a media type, whose names are
  # normalized here. Under a schema it is a JSON Schema keyword holding a plain
  # array instead, which has no names to normalize.
  def symbolize_examples(value)
    return symbolize(value) unless value.is_a?(Hash)

    result = {}
    value.each do |k, v|
      k = k.downcase.tr(' ', '_') unless k.is_a?(Symbol)

      result[k.to_sym] = symbolize(v)
    end
    result
  end

  # Normalizes the names of examples in place, for a document that already
  # holds symbol keys.
  def normalize_example_names!(value)
    case value
    when Hash
      value.each do |k, v|
        rename_examples!(v) if k == :examples && v.is_a?(Hash)
        normalize_example_names!(v)
      end
    when Array
      value.each { |v| normalize_example_names!(v) }
    end
    value
  end

  private

  def rename_examples!(examples)
    renamed = {}
    examples.each { |name, example| renamed[RSpec::OpenAPI::ExampleKey.normalize(name).to_sym] = example }
    examples.replace(renamed)
  end
end
