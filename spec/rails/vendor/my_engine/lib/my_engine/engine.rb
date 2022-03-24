# frozen_string_literal: true

module MyEngine
  class Engine < ::Rails::Engine
    isolate_namespace MyEngine
  end
end
