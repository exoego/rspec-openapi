class Masters::ExtensionsController < ApplicationController
  def index
    render json: [{ name: 'my-ext-1' }]
  end

  def create
    render json: { message: 'created' }
  end
end
