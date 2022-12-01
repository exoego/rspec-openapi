class UsersController < ApplicationController
  def show
    render json: find_user(params[:id])
  end

  private

  def find_user(id = nil)
    case id
    when '1', nil
      {
        name: 'John Doe',
        relations: {
          avatar: {
            url: 'https://example.com/avatar.jpg',
          },
          pets: [
            { name: 'doge', age: 8 },
          ],
        },
      }
    else
      raise NotFoundError
    end
  end
end
