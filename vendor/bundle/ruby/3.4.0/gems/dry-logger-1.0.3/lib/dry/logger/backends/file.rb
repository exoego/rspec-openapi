# frozen_string_literal: true

require "pathname"

require "dry/logger/backends/stream"

module Dry
  module Logger
    module Backends
      class File < Stream
        def initialize(stream:, **opts)
          Pathname(stream).dirname.mkpath
          super
        end
      end
    end
  end
end
