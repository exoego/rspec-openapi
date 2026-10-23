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

  def stringify(value)
    case value
    when Hash
      result = {}
      value.each { |k, v| result[key_string(k)] = stringify(v) }
      result
    when Array
      value.map { |v| stringify(v) }
    else
      value
    end
  end

  private

  # Symbol#name hands back the symbol's own frozen string, where to_s copies it
  # for every key of the document.
  if Symbol.method_defined?(:name)
    def key_string(key)
      key.is_a?(Symbol) ? key.name : key.to_s
    end
  else
    def key_string(key)
      key.to_s
    end
  end
end
