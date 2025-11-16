class ArrayHashesController < ApplicationController
  def index
    response = {
      "users" => [
        {
          "label" => "Jane Doe",
          "value" => "jane_doe"
        },
        {
          "label" => nil,
          "value" => "unknown",
          "invited" => true
        }
      ],
    }
    render json: response
  end
end
