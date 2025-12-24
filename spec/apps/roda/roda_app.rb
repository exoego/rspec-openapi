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

    r.on 'example_mode_roda' do
      # GET /example_mode_roda
      r.get do
        { status: 'roda_example' }
      end
    end

    r.on 'tags_roda' do
      # POST /tags_roda
      r.post do
        params = JSON.parse(request.body.read, symbolize_names: true)
        { created: true, tags: params[:names] }
      end
    end
  end
end
