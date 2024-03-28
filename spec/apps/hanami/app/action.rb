# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module HanamiTest
  class Action < Hanami::Action
    class RecordNotFound < StandardError; end
  end
end
