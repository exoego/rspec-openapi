# frozen_string_literal: true

require 'roda'

class RodaApp < Roda
  plugin :json, classes: [Array, Hash]

  route do |r|
    r.on 'roda' do
      # POST /roda
      r.post do
        params = JSON.parse(request.body.read, symbolize_names: true)
        params.merge({ name: 'hello' })
      end
    end
  end
end
