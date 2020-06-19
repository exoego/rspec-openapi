class TablesController < ApplicationController
  APIKEY = 'k0kubun'

  before_action :authenticate

  def index
    render json: [find_table]
  end

  def show
    render json: find_table(params[:id])
  end

  def create
    render json: find_table, status: 201
  end

  def update
    render json: find_table(params[:id])
  end

  def destroy
    render json: find_table(params[:id])
  end

  private

  def authenticate
    if params[:apikey] != APIKEY
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  def find_table(id = nil)
    case id
    when '1', nil
      {
        id: 1,
        name: 'access',
        description: nil,
        database: {
          id: 2,
          name: 'production',
        },
        created_at: Time.now,
        updated_at: Time.now,
      }
    else
      raise NotFoundError
    end
  end
end
