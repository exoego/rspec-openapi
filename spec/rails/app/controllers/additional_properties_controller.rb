class AdditionalPropertiesController < ApplicationController
  def index
    response = {
      required_key: 'value',
      variadic_key: {
        gold: 1,
        silver: 2,
        bronze: 3
      }
    }
    render json: response
  end
end
