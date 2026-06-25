# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'json'

# For Ruby 2.7
require 'date'

# TODO: Support JSON
class RSpec::OpenAPI::SchemaFile
  # @param [String] path
  def initialize(path)
    @path = path
  end

  # Reads the existing spec, lets the block mutate it, writes the result back
  # and returns the (symbolized) spec so it can be mirrored to other files.
  # @return [Hash]
  def edit(&block)
    spec = read
    block.call(spec)
    spec
  ensure
    write(spec)
  end

  # Writes an already-built spec to this file, choosing the format from the
  # file extension.
  # @param [Hash] spec
  def write(spec)
    stringified = RSpec::OpenAPI::KeyTransformer.stringify(spec)
    FileUtils.mkdir_p(File.dirname(@path))
    output =
      if json?
        JSON.pretty_generate(stringified)
      else
        prepend_comment(YAML.dump(stringified))
      end
    File.write(@path, output)
  end

  private

  # @return [Hash]
  def read
    return {} unless File.exist?(@path)

    content = YAML.safe_load(File.read(@path), permitted_classes: [Date, Time]) # this can also parse JSON
    return {} if content.nil?

    RSpec::OpenAPI::KeyTransformer.symbolize(content)
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
