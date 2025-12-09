require 'English'
require 'patience_diff/formatter'
require 'patience_diff/sequence_matcher'

module PatienceDiff
  class Differ
    attr_reader :matcher
    attr_accessor :all_context, :line_ending, :ignore_whitespace
    
    # Options:
    #   * :all_context: Output the entirety of each file. This overrides the sequence matcher's context setting.
    #   * :line_ending: Delimiter to use when joining diff output. Defaults to $RS.
    #   * :ignore_whitespace: Before comparing lines, strip trailing whitespace, and treat leading whitespace 
    #     as either present or not. Does not affect output.
    # Any additional options (e.g. :context) are passed on to the sequence matcher.
    def initialize(opts = {})
      @all_context = opts.delete(:all_context)
      @line_ending = opts.delete(:line_ending) || $RS
      @ignore_whitespace = opts.delete(:ignore_whitespace)
      @matcher = SequenceMatcher.new(opts)
    end
    
    # Generates a unified diff from the contents of the files at the paths specified.
    def diff_files(left_file, right_file, formatter=Formatter.new)
      (left_data, left_timestamp), (right_data, right_timestamp) = [left_file, right_file].map do |filename|
        # Read in binary encoding, so that we can diff any encoding and split() won't complain
        File.open(filename, :external_encoding => Encoding::BINARY) do |file|
          [file.read.split($RS), file.mtime]
        end
      end
      diff_sequences(left_data, right_data, left_file, right_file, left_timestamp, right_timestamp, formatter)
    end
    
    # Generate a unified diff of the data specified. The left and right values should be strings, or any other indexable, sortable data.
    # File names and timestamps do not affect the diff algorithm, but are used in the header text.
    def diff_sequences(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil, formatter=Formatter.new)
      if @ignore_whitespace
        a = left.map  { |line| line.rstrip.gsub(/^\s+/, ' ') }
        b = right.map { |line| line.rstrip.gsub(/^\s+/, ' ') }
      else
        a = left
        b = right
      end
      
      if @all_context
        hunks = [@matcher.diff_opcodes(a, b)]
      else
        hunks = @matcher.grouped_opcodes(a, b)
      end
      
      return nil unless hunks.any?
      
      lines = []
      lines << formatter.render_header(left_name, right_name, left_timestamp, right_timestamp)
      last_hunk_end = -1
      hunks.each do |opcodes|
        lines << formatter.render_hunk(a, b, opcodes, last_hunk_end)
        last_hunk_end = opcodes.last[4]
      end
      lines.flatten.compact.join(@line_ending) + @line_ending
    end
  end
end
