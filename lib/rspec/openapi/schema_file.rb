require 'fileutils'
require 'yaml'

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
    write(spec)
  end

  private

  # @return [Hash]
  def read
    return {} unless File.exist?(@path)
    YAML.load(File.read(@path))
  end

  # @param [Hash] spec
  def write(spec)
    FileUtils.mkdir_p(File.dirname(@path))
    File.write(@path, prepend_comment(YAML.dump(spec)))
  end

  def prepend_comment(content)
    return content if RSpec::OpenAPI.comment.nil?

    comment = RSpec::OpenAPI.comment.dup
    unless comment.end_with?("\n")
      comment << "\n"
    end
    "#{comment.gsub(/^/, '# ').gsub(/^# \n/, "#\n")}#{content}"
  end
end
