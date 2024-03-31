# frozen_string_literal: true

require "hanami"

module HanamiTest
  class App < Hanami::App
    config.middleware.use :body_parser, :json
  end
end
