class TablesController < ApplicationController
  APIKEY = 'k0kubun'

  before_action :authenticate

  def index
    response.set_header('X-Cursor', 100)
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
    if params[:no_content]
      return head 202
    end

    render json: find_table(params[:id])
  end

  private

  def authenticate
    if request.headers[:authorization] != APIKEY
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  def find_table(id = nil)
    time = Time.parse('2020-07-17 00:00:00')
    case id
    when '1', nil
      {
        id: 1,
        name: 'access',
        description: 'logs',
        database: {
          id: 2,
          name: 'production',
        },
        null_sample: nil,
        storage_size: 12.3,
        created_at: time.iso8601,
        updated_at: time.iso8601,
      }
    else
      raise NotFoundError
    end
  end
end
