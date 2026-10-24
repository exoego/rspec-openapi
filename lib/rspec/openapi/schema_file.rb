# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require 'json'
require 'stringio'

# For Ruby 2.7
require 'date'

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
  # file extension. Both formats write the symbol keys as strings themselves.
  # @param [Hash] spec
  def write(spec)
    FileUtils.mkdir_p(File.dirname(@path))
    File.write(@path, json? ? JSON.pretty_generate(spec) : yaml_document(spec))
  end

  private

  # @return [Hash]
  def read
    return {} unless File.exist?(@path)

    content = File.read(@path)
    spec = json? ? read_json(content) : RSpec::OpenAPI::YAMLLoader.load(content)
    spec.nil? ? {} : spec
  end

  def read_json(content)
    return nil if content.match?(/\A\s*\z/)

    spec = JSON.parse(content, symbolize_names: true, max_nesting: false)
    RSpec::OpenAPI::KeyTransformer.normalize_example_names!(spec)
  end

  def yaml_document(spec)
    io = StringIO.new(+'')
    io.write(comment_lines) unless RSpec::OpenAPI.comment.nil?
    RSpec::OpenAPI::YAMLDumper.dump(spec, io)
    io.string
  end

  def comment_lines
    comment = RSpec::OpenAPI.comment.dup
    comment << "\n" unless comment.end_with?("\n")
    comment.gsub(/^/, '# ').gsub(/^# \n/, "#\n")
  end

  def json?
    File.extname(@path) == '.json'
  end
end
