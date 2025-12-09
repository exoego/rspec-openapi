# frozen_string_literal: true

require "concurrent/map"

module Dry
  module Events
    include ::Dry::Core::Constants

    LISTENERS_HASH = ::Concurrent::Map.new do |h, k|
      h.compute_if_absent(k) { [] }
    end
  end
end
