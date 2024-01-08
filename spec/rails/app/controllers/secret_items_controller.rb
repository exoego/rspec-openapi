class SecretItemsController < ApplicationController
  before_action :authenticate_api_key!

  def index
    render json: { items: ['secrets'] }
  end

  private

  def authenticate_api_key!
    if request.env['Secret-Key'] != '42'
      head :unauthorized
    end
  end
end