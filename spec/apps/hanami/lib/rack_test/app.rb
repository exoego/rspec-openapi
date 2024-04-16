# frozen_string_literal: true

module RackTest
  class App
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      path = req.path_info

      case path
      when "/rack/foo"
        [200, { 'Content-Type' => 'text/plain' }, ['A RACK FOO']]
      when "/rack/bar"
        [200, { 'Content-Type' => 'text/plain' }, ['A RACK BAR']]
      else
        return @app.call(env)
      end
    end
  end
end
