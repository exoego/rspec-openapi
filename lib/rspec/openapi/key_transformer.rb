# frozen_string_literal: true

class << RSpec::OpenAPI::KeyTransformer = Object.new
  def symbolize(value)
    case value
    when Hash
      value.to_h { |k, v| [k.to_sym, symbolize(v)] }
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
