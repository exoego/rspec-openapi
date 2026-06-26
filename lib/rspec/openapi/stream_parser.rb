# frozen_string_literal: true

require 'json'

# Splits a streaming body into its items (for `itemSchema`), skipping unparseable
# chunks. Supported content types: RSpec::OpenAPI::SEQUENTIAL_MEDIA_TYPES.
class << RSpec::OpenAPI::StreamParser = Object.new
  def items(raw, content_type)
    chunks =
      case content_type
      when 'application/json-seq' then raw.split("\x1e") # RFC 7464 record separator
      when 'text/event-stream' then sse_data(raw)
      else raw.split("\n") # NDJSON / JSON Lines
      end

    chunks.filter_map { |chunk| parse_json(chunk) }
  end

  private

  def parse_json(chunk)
    text = chunk.to_s.strip
    return nil if text.empty?

    JSON.parse(text)
  rescue JSON::ParserError
    nil
  end

  # SSE: events are blank-line separated; join the `data:` lines of each.
  def sse_data(raw)
    events = []
    current = []
    raw.each_line do |line|
      line = line.chomp
      if line.empty?
        events << current.join("\n") unless current.empty?
        current = []
      elsif line.start_with?('data:')
        current << line.sub(/\Adata: ?/, '')
      end
    end
    events << current.join("\n") unless current.empty?
    events
  end
end
