class ImagesController < ApplicationController
  def show
    send_image
  end

  def index
    list = [
      {
        'name': 'file.png',
        'tags': [], # Keep this empty to check empty array is accepted
      },
    ]
    render json: list
  end

  def upload
    send_image
  end

  def upload_nested
    send_image
  end

  def upload_multiple
    send_image
  end

  private

  def send_image
    png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
    QBoAAAAASUVORK5CYII='.unpack('m').first
    send_data png, type: 'image/png', disposition: 'inline'
  end
end
