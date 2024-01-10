class OptionalParamsController < ApplicationController
  def display
    render json: { id: params[:id] || 'id' }
  end
end
