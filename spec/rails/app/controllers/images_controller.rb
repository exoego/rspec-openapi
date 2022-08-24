class ImagesController < ApplicationController
  def show
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack('m').first
    send_data png, type: 'image/png', disposition: 'inline'
  end

  def index
    list = [
      {
        'name': 'file.png',
        'tags': [], # Keep this empty to check empty array is accepted
      }
    ]
    render json: list
  end
end
