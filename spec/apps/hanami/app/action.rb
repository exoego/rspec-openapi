# auto_register: false
# frozen_string_literal: true

require 'hanami/action'

class HanamiTest::Action < Hanami::Action
  class RecordNotFound < StandardError; end
end
