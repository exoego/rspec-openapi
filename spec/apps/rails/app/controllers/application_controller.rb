class ApplicationController < ActionController::Base
  NotFoundError = Class.new(StandardError)

  rescue_from NotFoundError do
    render json: { message: 'not found' }, status: 404
  end
end
