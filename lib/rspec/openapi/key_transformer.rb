# frozen_string_literal: true

class << RSpec::OpenAPI::KeyTransformer = Object.new
  def symbolize(value)
    case value
    when Hash
      value.to_h do |k, v|
        if k.to_sym == :examples
          [k.to_sym, symbolize_examples(v)]
        else
          [k.to_sym, symbolize(v)]
        end
      end
    when Array
      value.map { |v| symbolize(v) }
    else
      value
    end
  end

  def symbolize_examples(value)
    case value
    when Hash
      value.to_h do |k, v|
        k = k.downcase.tr(' ', '_') unless k.is_a?(Symbol)

        [k.to_sym, symbolize(v)]
      end
    when Array
      value.map { |v| symbolize(v) }
    else
      value
    end
  end

  def stringify(value)
    case value
    when Hash
      value.to_h { |k, v| [k.to_s, stringify(v)] }
    when Array
      value.map { |v| stringify(v) }
    else
      value
    end
  end
end
