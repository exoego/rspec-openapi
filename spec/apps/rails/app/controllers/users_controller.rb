class UsersController < ApplicationController
  def create
    res = {
      name: params[:name] || 'alice',
      relations: {
        avatar: {
          url: params[:avatar_url] || 'https://example.com/avatar.png',
        },
        pets: params[:pets] || [],
      },
    }
    render json: res, status: 201
  end

  def show
    render json: find_user(params[:id])
  end

  def active
    render json: find_user(params[:id]).present?
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
    when '2'
      {}
    else
      raise NotFoundError
    end
  end
end
