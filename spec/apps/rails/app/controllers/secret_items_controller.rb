class SecretItemsController < ApplicationController
  def index
    render json: { items: ['secrets'] }
  end
end
