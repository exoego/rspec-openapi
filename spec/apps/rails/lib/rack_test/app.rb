# frozen_string_literal: true

module RackTest
  class App
    def call(env)
      req = Rack::Request.new(env)
      path = req.path_info

      case path
      when "/foo"
        [200, { 'Content-Type' => 'text/plain' }, ['A RACK FOO']]
      when "/bar"
        [200, { 'Content-Type' => 'text/plain' }, ['A RACK BAR']]
      end
    end
  end
end
