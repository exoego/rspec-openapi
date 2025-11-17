class ArrayHashesController < ApplicationController
  def nullable
    response = {
      "users" => [
        {
          "label" => "John Doe",
          "value" => "john_doe",
          "admin" => true
        },
        {
          "label" => "Jane Doe",
          "value" => "jane_doe"
        },
        {
          "label" => nil,
          "value" => "invited",
          "invited" => true
        },
      ],
    }
    render json: response
  end

  def non_nullable
    response = {
      "users" => [
        {
          "label" => "Jane Doe",
          "value" => "jane_doe"
        },
        {
          "label" => "John Doe",
          "value" => "john_doe"
        }
      ],
    }
    render json: response
  end
end
