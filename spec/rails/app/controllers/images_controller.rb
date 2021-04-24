class ImagesController < ApplicationController
  def show
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack('m').first
    send_data png, type: 'image/png', disposition: 'inline'
  end
end
