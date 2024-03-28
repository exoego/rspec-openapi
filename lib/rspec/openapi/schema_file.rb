# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'json'

# TODO: Support JSON
class RSpec::OpenAPI::SchemaFile
  # @param [String] path
  def initialize(path)
    @path = path
  end

  def edit(&block)
    spec = read
    block.call(spec)
  ensure
    write(stringify(spec))
  end

  private

  # @return [Hash]
  def read
    return {} unless File.exist?(@path)

    symbolize(YAML.safe_load(File.read(@path))) # this can also parse JSON
  end

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

  # @param [Hash] spec
  def write(spec)
    FileUtils.mkdir_p(File.dirname(@path))
    output =
      if json?
        JSON.pretty_generate(spec)
      else
        prepend_comment(YAML.dump(spec))
      end
    File.write(@path, output)
  end

  def prepend_comment(content)
    return content if RSpec::OpenAPI.comment.nil?

    comment = RSpec::OpenAPI.comment.dup
    comment << "\n" unless comment.end_with?("\n")
    "#{comment.gsub(/^/, '# ').gsub(/^# \n/, "#\n")}#{content}"
  end

  def json?
    File.extname(@path) == '.json'
  end
end
