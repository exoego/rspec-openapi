require 'stringio'

module PatienceDiff
  # Delegate object yielded by the #format method.
  class FormattingContext
    def initialize(differ, formatter)
      @differ = differ
      @formatter = formatter
      @out = StringIO.new
    end
    
    def files(left_file, right_file)
      @out.print @differ.diff_files(left_file, right_file, @formatter)
    end
    
    def sequences(left, right, left_name=nil, right_name=nil, left_timestamp=nil, right_timestamp=nil)
      @out.print @differ.diff_sequences(left, right, left_name, right_name, left_timestamp, right_timestamp, @formatter)
    end
    
    def orphan(sequence, name=nil, timestamp=nil)
      @out.print @formatter.render_orphan(sequence, name, timestamp)
    end
    
    def format
      @out.string
    end
    
    def title
      @formatter.title
    end
    
    def names
      @formatter.names
    end
  end
end
