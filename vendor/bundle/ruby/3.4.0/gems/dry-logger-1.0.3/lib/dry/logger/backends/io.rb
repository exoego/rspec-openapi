# frozen_string_literal: true

require "dry/logger/backends/stream"

module Dry
  module Logger
    module Backends
      class IO < Stream
        def close
          super unless stream.equal?($stdout)
        end
      end
    end
  end
end
