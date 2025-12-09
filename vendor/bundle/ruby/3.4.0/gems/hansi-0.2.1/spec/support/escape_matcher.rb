RSpec::Matchers.define :escape do |*args|
  match do |renderer|
    begin
      @rendered = renderer.escape(*args)
    rescue Exception => e
      @exception = e
      false
    else
      if @expected ||= nil
        @rendered == @expected
      else
        !!@rendered
      end
    end
  end

  chain :as do |result|
    @expected = result
  end

  failure_message do |renderer|
    if @exception ||= nil
      "expected %p to escape %p, but got exception: %p" % [renderer, args, @exception]
    else
      "expected %p to escape %p as %p, but got %p" % [render, args, @expected, @rendered]
    end
  end
end