# frozen_string_literal: true

module Dry
  module System
    include Dry::Core::Constants

    RB_EXT = ".rb"
    RB_GLOB = "*.rb"
    PATH_SEPARATOR = File::SEPARATOR
    KEY_SEPARATOR = "."
    WORD_REGEX = /\w+/
  end
end
