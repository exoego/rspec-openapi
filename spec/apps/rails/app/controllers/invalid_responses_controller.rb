# frozen_string_literal: true

class InvalidResponsesController < ApplicationController
  def show
    render json: {
      payload: {
        message: 'invalid payload example',
        requested_at: Time.current,
      },
    }
  end
end
