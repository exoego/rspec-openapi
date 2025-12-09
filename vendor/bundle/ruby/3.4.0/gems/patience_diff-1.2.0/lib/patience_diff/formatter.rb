require 'patience_diff/formatting_context'

module PatienceDiff
  # Formats a plaintext unified diff.
  class Formatter
    attr_reader :names
    attr_accessor :left_name, :right_name, :left_timestamp, :right_timestamp, :title
    
    def initialize(differ, title = nil)
      @differ = differ
      @names = []
      @title = title || "Diff generated on #{Time.now.strftime('%c')}"
    end
        
    def format
      context = FormattingContext.new(@differ, self)
      yield context
      context.format
    end
    
    def render_header(left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
      @names << right_name
      @left_name = left_name || "Original"
      @right_name = right_name || "Current"
      @left_timestamp = left_timestamp || Time.now
      @right_timestamp = right_timestamp || Time.now
      [
        left_header_line(@left_name, @left_timestamp),
        right_header_line(@right_name, @right_timestamp)
      ]
    end
    
    def render_hunk_marker(opcodes)
      a_start = opcodes.first[1] + 1
      a_end = opcodes.last[2] + 2
      b_start = opcodes.first[3] + 1
      b_end = opcodes.last[4] + 2
      
      "@@ -%d,%d +%d,%d @@" % [a_start, a_end-a_start, b_start, b_end-b_start]
    end
    
    def render_hunk(a, b, opcodes, last_line_shown)
      lines = [render_hunk_marker(opcodes)]
      lines << opcodes.collect do |(code, a_start, a_end, b_start, b_end)|
        case code
        when :equal 
          b[b_start..b_end].map { |line| ' ' + line }
        when :delete
          a[a_start..a_end].map { |line| '-' + line }
        when :insert
          b[b_start..b_end].map { |line| '+' + line }
        end
      end
      lines
    end
    
    private
    def left_header_line(name, timestamp)
      "--- %s\t%s" % [name, timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")]
    end
    
    def right_header_line(name, timestamp)
      "+++ %s\t%s" % [name, timestamp.strftime("%Y-%m-%d %H:%m:%S.%N %z")]
    end
  end
end
