module PatienceDiff
  # Matches indexed data (generally text) using the Patience diff algorithm.
  class SequenceMatcher
    attr_accessor :context
    
    Card = Struct.new(:index, :value, :previous)
    
    # Options:
    #   * :context: number of lines of context to use when grouping
    def initialize(opts = {})
      @context = opts[:context] || 3
    end
    
    # Generate a diff of a and b using #diff_opcodes, and split the opcode into groups
    # whenever an :equal range is encountered that is longer than @context * 2.
    # Returns an array of arrays of 5-tuples as described for #diff_opcodes.
    def grouped_opcodes(a, b)
      groups = []
      last_group = []
      diff_opcodes(a, b).each do |opcode|
        if opcode[0] == :equal
          if @context.zero?
            groups << last_group
            last_group = []
            next
          end
          
          code, a_start, a_end, b_start, b_end = *opcode
          
          if (a_start.zero? and b_start.zero?) or (a_end == a.length-1 and b_end == b.length-1)
            threshold = @context
          else
            threshold = @context * 2
          end
          
          if (b_end - b_start + 1) > threshold
            unless last_group.empty?
              last_group << [
                code,
                a_start,
                a_start + @context - 1,
                b_start,
                b_start + @context - 1
              ]
              groups << last_group
              last_group = []
            end
            opcode = [
              code, 
              a_end - @context + 1,
              a_end,
              b_end - @context + 1,
              b_end
            ]
          end
        end
        last_group << opcode
      end
      groups << last_group unless last_group.one? and last_group.first[0] == :equal
      groups
    end
    
    # Generate a diff of a and b, and return an array of opcodes describing that diff.
    # Each opcode represents a range in a and b that is either equal, only in a,
    # or only in b. Opcodes are 5-tuples, in the format:
    #   0: code
    #      A symbol indicating the diff operation. Can be :equal, :delete, or :insert.
    #   1: a_start
    #      Index in a where the range begins
    #   2: a_end
    #      Index in a where the range ends.
    #   3: b_start
    #      Index in b where the range begins
    #   4: b_end
    #      Index in b where the range ends.
    #
    # For :equal, (a_end - a_start) == (b_end - b_start).
    # For :delete, a_start == a_end.
    # For :insert, b_start == b_end.
    def diff_opcodes(a, b)
      sequences = collapse_matches(match(a, b))
      sequences << [a.length, b.length, 0]
  
      a_pos = b_pos = 0
      opcodes = []
      sequences.each do |(i, j, len)|
        if a_pos < i
          opcodes << [:delete, a_pos, i-1, b_pos, b_pos]
        end
        if b_pos < j
          opcodes << [:insert, a_pos, a_pos, b_pos, j-1]
        end
        if len > 0
          opcodes << [:equal, i, i+len-1, j, j+len-1]
        end
        a_pos = i+len
        b_pos = j+len
      end
      opcodes
    end
      
    private
    def match(a, b)
      matches = []
      recursively_match(a, b, 0, 0, a.length, b.length) do |match|
        matches << match
      end
      matches
    end
    
    def recursively_match(a, b, a_lo, b_lo, a_hi, b_hi)
      return if a_lo == a_hi or b_lo == b_hi

      last_a_pos = a_lo - 1
      last_b_pos = b_lo - 1
      
      longest_unique_subsequence(a[a_lo...a_hi], b[b_lo...b_hi]).each do |(a_pos, b_pos)|
        # recurse betwen unique lines
        a_pos += a_lo
        b_pos += b_lo
        if (last_a_pos+1 != a_pos) or (last_b_pos+1 != b_pos)
          recursively_match(a, b, last_a_pos+1, last_b_pos+1, a_pos, b_pos) { |match| yield match }
        end
        last_a_pos = a_pos
        last_b_pos = b_pos
        yield [a_pos, b_pos]
      end
      
      if last_a_pos >= a_lo or last_b_pos >= b_lo
        # there was at least one match
        # recurse between last match and end
        recursively_match(a, b, last_a_pos+1, last_b_pos+1, a_hi, b_hi) { |match| yield match }
      elsif a[a_lo] == b[b_lo]
        # no unique lines
        # diff forward from beginning
        while a_lo < a_hi and b_lo < b_hi and a[a_lo] == b[b_lo]
          yield [a_lo, b_lo]
          a_lo += 1
          b_lo += 1
        end
        recursively_match(a, b, a_lo, b_lo, a_hi, b_hi) { |match| yield match }
      elsif a[a_hi-1] == b[b_hi-1]
        # no unique lines
        # diff back from end
        a_mid = a_hi - 1
        b_mid = b_hi - 1
        while a_mid > a_lo and b_mid > b_lo and a[a_mid-1] == b[b_mid-1]
          a_mid -= 1
          b_mid -= 1
        end
        recursively_match(a, b, a_lo, b_lo, a_mid, b_mid) { |match| yield match }
        (0...(a_hi-a_mid)).each do |i|
          yield [a_mid+i, b_mid+i]
        end
      end
    end
    
    def collapse_matches(matches)
      return [] if matches.empty?
      sequences = []
      start_a, start_b = *(matches.first)
      len = 1
      matches[1..-1].each do |(i_a, i_b)|
        if i_a == start_a + len and i_b == start_b + len
          len += 1
        else
          sequences << [start_a, start_b, len]
          start_a = i_a
          start_b = i_b
          len = 1
        end
      end
      sequences << [start_a, start_b, len]
      sequences
    end
  
    def longest_unique_subsequence(a, b)
      deck = Array.new(b.length)
      unique_a = {}
      unique_b = {}
      
      a.each_with_index do |val, index|
        if unique_a.has_key? val
          unique_a[val] = nil
        else
          unique_a[val] = index
        end
      end
      
      b.each_with_index do |val, index|
        a_index = unique_a[val]
        next unless a_index
        dupe_index = unique_b[val]
        if dupe_index
          deck[dupe_index] = nil
          unique_a.delete(val)
        else
          unique_b[val] = index
          deck[index] = a_index
        end
      end
      
      card = patience_sort(deck).last
      result = []
      while card
        result.unshift [card.value, card.index]
        card = card.previous
      end
      result
    end
  
    def patience_sort(deck)
      piles = []
      pile = 0
      deck.each_with_index do |card_value, index|
        next if card_value.nil?
        card = Card.new(index, card_value)
        
        if piles.any? and piles.last.value < card_value
          pile = piles.size
        elsif piles.any? and piles[pile].value < card_value and 
              (pile == piles.size-1 or piles[pile+1].value > card_value)
          pile += 1
        else
          pile = bisect(piles, card_value)
        end
        
        card.previous = piles[pile-1] if pile > 0
        
        if pile < piles.size
          #puts "putting card #{card.value} on pile #{pile}"
          piles[pile] = card
        else
          #puts "putting card #{card.value} on new pile"
          piles << card
        end
      end
      
      piles
    end
    
    def bisect(piles, target)
      low = 0
      high = piles.size - 1
      while (low <= high)
        mid = (low + high)/2
        if piles[mid].value < target
          low = mid + 1
        else
          high = mid - 1
        end
      end
      low
    end
  end
end
