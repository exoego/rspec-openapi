RSpec::Matchers.define :parse do |*args|
  match do |parser|
    begin
      @parsed = parser.parse(*args)
    rescue Exception => e
      @exception = e
      false
    else
      if @expected ||= nil
        @parsed == @expected
      else
        !!@parsed
      end
    end
  end

  chain :as do |*result|
    @expected = parser.parse(*result)
  end

  failure_message do |parser|
    if @exception ||= nil
      "expected %p to parse %p, but got exception: %p" % [parser, args, @exception]
    else
      "expected %p to parse %p as %p, but got %p" % [parser, args, @expected, @parsed]
    end
  end
end