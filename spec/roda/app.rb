require 'roda'

class App < Roda
  plugin :json, classes: [Array, Hash]

  route do |r|
    r.on 'roda' do
      # POST /roda
      r.post do
        {
          id: 1,
          name: 'hello',
        }
      end
    end
  end
end
